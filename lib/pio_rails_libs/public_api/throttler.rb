# a simple throttler to rate limit public api requests
module PublicApi
  class Throttler
    attr_reader :redis, :key, :period, :limit

    def initialize(redis:, key:, period:, limit:)
      @redis = redis
      @key = key
      @period = period.to_i
      @limit = limit.to_i
    end

    def throttled?
      redis_key = derive_redis_key
      count = redis.get(redis_key)
      return true if count.present? && count.to_i >= limit

      redis.multi do
        redis.incr(redis_key)
        redis.expire(redis_key, period)
      end
      false
    end

    private

    def derive_redis_key
      time_key = Time.now.to_i / period
      "public_api:throttler:#{key}:#{time_key}"
    end
  end
end
