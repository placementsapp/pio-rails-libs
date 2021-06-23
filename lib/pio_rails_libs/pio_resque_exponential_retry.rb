# Simple exponential retry, adapted from
#  https://github.com/lantins/resque-retry/blob/master/lib/resque/plugins/exponential_backoff.rb
#  just extend this in your actual job
module PioResqueExponentialRetry
  def backoff_strategy
    # default:            0s, 1m, 10m, 1h,   3h,     6h
    @backoff_strategy ||= [0, 60, 600, 3600, 10_800, 21_600]
  end

  def retry_limit
    @retry_limit ||= backoff_strategy.length
  end

  def retry_delay(exception_class = nil)
    delay = backoff_strategy[retry_attempt] || backoff_strategy.last
    # add some jitter to avoid thundering herd
    (delay * rand(1.0..1.5)).to_i
  end
end
