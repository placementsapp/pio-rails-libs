require 'resque'
require 'resque-retry'
require 'resque/failure/redis'

# default backend dumps entire `exception.to_s`, which can be huge.
#  see https://github.com/placementsapp/placements-V4.1/issues/8795
class Resque::Failure::RedisWithTruncatedError < Resque::Failure::Redis
  def save
    error = UTF8Util.clean(exception.to_s)
    error = error[0..900] + '...' + error[-100..-1] if error.size > 1000

    data = {
      :failed_at => UTF8Util.clean(Time.now.strftime("%Y/%m/%d %H:%M:%S %Z")),
      :payload   => payload,
      :exception => exception.class.to_s,
      :error     => error,
      :backtrace => filter_backtrace(Array(exception.backtrace)),
      :worker    => worker.to_s,
      :queue     => queue
    }
    data = Resque.encode(data)
    data_store.push_to_failed_queue(data)
  end
end
