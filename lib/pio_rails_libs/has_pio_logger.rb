require 'active_support/all'

# include this module for instance/class level `logger` (of type `PioLogger`)
module HasPioLogger
  extend ActiveSupport::Concern

  class_methods do
    def logger
      @logger = PioLogger.new(source: self.name)
    end
  end

  def logger
    self.class.logger
  end

  # thin wrapper around Rails.logger, to automatically include diagnostic context
  #  if we need more functionality, probably should adopt `logging` gem instead
  class PioLogger
    attr_reader :source, :logger

    delegate :debug?, :info?, :warn?, :error?, :fatal?, to: :logger

    def initialize(source: 'Rails', logger: Rails.logger)
      @source = source
      @logger = logger
    end

    [:debug, :info, :warn, :error, :fatal].each do |level|
      define_method(level) do |message_or_progname = nil, &block|
        logger.tagged(*context_tags) { logger.public_send(level, message_or_progname, &block) }
      end
    end

    def context_tags
      PioDiagnostics.context.except(:controller, :action).map { |k, v| "#{k}:#{v}" } << "source:#{source}"
    end
  end
end
