require 'resque'
require 'resque-retry'
require 'resque/plugins/heroku'

# abstract base class for background jobs
class PioResqueJob
  include HasPioLogger

  extend Resque::Plugins::Retry
  extend Resque::Plugins::Heroku
  extend Resque::Plugins::PioMultipleDb

  # simple wrapper of Resque.enqueue, adding job metadata
  def self.enqueue(klass, *args)
    ensure_job_meta!(args)
    args.last['pio_job_id'] if Resque.enqueue(klass, *args)
  end

  # simple wrapper of Resque.enqueue_in, adding job metadata
  def self.enqueue_in(delay, klass, *args)
    ensure_job_meta!(args)
    args.last['pio_job_id'] if Resque.enqueue_in(delay, klass, *args)
  end

  # simple wrapper of Resque.enqueue_to, adding job metadata
  def self.enqueue_to(queue, klass, *args)
    ensure_job_meta!(args)
    args.last['pio_job_id'] if Resque.enqueue_to(queue, klass, *args)
  end

  # for scheduled job with metadata
  def self.scheduled(queue, _klass_name, *args)
    enqueue_to(queue, self, *args)
  end

  # try to cancel a job with the job_id - attempt with best effort
  def self.try_cancel(job_id)
    Resque.redis.set(cancel_key(job_id), "", ex: 1.day)
  end

  # derived class need to define .perform_internal, where job metadata is not needed
  # NOTE: unfortunately, hooks still need to be aware of existence of job metadata!
  def self.perform(*args)
    job_meta = extract_job_meta!(args)
    should_perform = job_meta.blank? || !Resque.redis.exists?(cancel_key(job_meta['pio_job_id']))
    if should_perform
      PioDiagnostics.context.update(
        pio_job_class: self.name,
        pio_job_id: job_meta['pio_job_id'],
        job_arguments: args
      )
      Honeybadger.context(PioDiagnostics.context)
      perform_internal(*args)
    end
  end

  # customize resque-retry to expire stale keys
  def self.expire_retry_key_after
    3.days
  end

  # customize resque-retry to not count as retries on certain exceptions
  def self.ignore_exceptions
    [Resque::TermException]
  end

  def self.retry_args(*args)
    ensure_job_meta!(args)
  end

  def self.retry_identifier(*args)
    job_meta = extract_job_meta!(args)
    if job_meta.key?('pio_job_id')
      job_meta['pio_job_id']
    else
      args_string = args.join('-')
      args_string.empty? ? nil : Digest::SHA1.hexdigest(args_string)
    end
  end

  # hook for logging
  def self.around_perform_log_metrics(*args)
    job_meta = extract_job_meta!(args)
    Rails.logger.info "STARTING Job #{self}, id: #{job_meta['pio_job_id']}, args: #{args.inspect}"

    start = Time.now
    queued_ms = job_meta.key?('enqueued_at') ? (start - Time.at(job_meta['enqueued_at'].to_i)) * 1000 : nil
    yield

    Rails.logger.info "COMPLETED Job #{self}, id: #{job_meta['pio_job_id']}, args: #{args.inspect}"
    job_status = 'success'
  rescue Object => e
    job_status = 'failed'
    raise e
  ensure
    elapsed_ms = (Time.now - start) * 1000
    PioMetrics.publish('Resque', job: self.name, status: job_status, elapsed_ms: elapsed_ms, queued_ms: queued_ms, id: job_meta['pio_job_id'])
  end

  # hook for resque-retry before re-enqueue
  try_again_callback do |exception, *args|
    log_and_report_failure(exception, args, temporary: true)
  end

  # hook for resque-retry before finally giving up
  give_up_callback do |exception, *args|
    log_and_report_failure(exception, args, temporary: false)
  end

  def self.log_and_report_failure(exception, args, temporary:)
    job_meta = extract_job_meta!(args)
    if temporary
      Rails.logger.info "Job #{self} will be retried, id: #{job_meta['pio_job_id']}, exception: #{exception.inspect.truncate(1000).gsub("\n", ' ')}, args: #{args.inspect}"
    else
      Rails.logger.error "Job #{self} failed, will NOT retry, id: #{job_meta['pio_job_id']}, exception: #{exception.inspect.truncate(1000).gsub("\n", ' ')}, args: #{args.inspect}"
      Honeybadger.notify(exception, context: PioDiagnostics.context, sync: true)
    end
  end

  def self.ensure_job_meta!(args)
    job_meta = extract_job_meta!(args)
    if job_meta.blank?
      job_meta = {
        'pio_job_id' => SecureRandom.uuid
      }
    end

    job_meta["enqueued_at"] = Time.now.to_i
    args << job_meta
  end

  def self.extract_job_meta!(args)
    if args.last.is_a?(Hash) && args.last.key?('pio_job_id')
      args.pop
    else
      {}
    end
  end

  def self.cancel_key(job_id)
    "cancel_job:#{job_id}"
  end

  # Follows pattern established in `ApplicationController#set_locale_by_org`.
  def self.set_locale_by_org(org)
    if (
      org.org_locale.present? &&
      I18n.locale_available?(org.org_locale)
    )
      I18n.locale = org.org_locale
    else
      I18n.locale = 'en'
    end
  end
end
