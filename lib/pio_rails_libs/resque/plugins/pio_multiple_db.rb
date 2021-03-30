module Resque::Plugins::PioMultipleDb
  def after_perform_pio_multiple_db(*args)
    if !Resque.inline? && 'true' == ENV['PIO_MULTIPLE_DB']&.downcase
      PioMultipleDb.clear_connections!
    end
  end

  def on_failure_pio_multiple_db(e, *args)
    if !Resque.inline? && 'true' == ENV['PIO_MULTIPLE_DB']&.downcase
      PioMultipleDb.clear_connections!
    end
  end
end
