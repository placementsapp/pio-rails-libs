# to publish metrics (currently just to log)
module PioMetrics
  def self.publish(name, metrics_hash)
    metrics_string = metrics_hash.map { |k,v| "#{k}:#{v}" }.join(' ')
    Rails.logger.info "[PioMetrics:#{name} #{metrics_string}]"
  end
end
