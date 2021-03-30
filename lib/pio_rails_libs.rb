require "pio_rails_libs/version"

require "pio_rails_libs/has_pio_logger"
require "pio_rails_libs/pio_diagnostics"
require "pio_rails_libs/pio_metrics"

require "pio_rails_libs/pio_multiple_db"

require 'pio_rails_libs/pio_resque_exponential_retry'
require 'pio_rails_libs/resque/failure/redis_with_truncated_error'
require 'pio_rails_libs/resque/plugins/pio_multiple_db'
require 'pio_rails_libs/pio_resque_job'
require 'pio_rails_libs/active_job/queue_adapters/pio_resque_job_adapter'

module PioRailsLibs
  class Error < StandardError; end
  # Your code goes here...
end