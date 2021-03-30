# Hook up ActiveJob, adapted from ActiveJob::QueueAdapters::ResqueAdapter
#  for now, it is only used for mail delivery
module ActiveJob
  module QueueAdapters
    class PioResqueJobAdapter
      def enqueue(job)
        JobWrapper.instance_variable_set(:@queue, job.queue_name)
        PioResqueJob.enqueue_to(job.queue_name, JobWrapper, job.serialize)
      end

      def enqueue_at(job, timestamp)
        raise 'not supported yet!'
      end

      class JobWrapper < ::PioResqueJob
        extend PioResqueExponentialRetry

        @queue = :general

        def self.perform_internal(job_data)
          ActiveJob::Base.execute(job_data)
        end
      end
    end
  end
end
