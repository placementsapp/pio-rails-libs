# Rails 6 has built-in multiple DB support, see https://guides.rubyonrails.org/active_record_multiple_databases.html
#  for now this is probably good enough
class PioMultipleDb
  # establish connections to other DBs
  def self.establish_connections
    resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(ActiveRecord::Base.configurations)

    other_connection_names.map do |cn|
      ActiveRecord::Base.connection_handler.establish_connection(resolver.spec(cn.to_sym).to_hash)
    end
  end

  # clean up all connections
  def self.clear_connections!
    ActiveRecord::Base.connection_handler.clear_all_connections!
  end

  # for now, just one additional DB to connect to: "_readonly"
  def self.other_connection_names
    [readonly_connection_name]
  end

  def self.readonly_connection_name
    "#{Rails.env}_readonly"
  end

  def self.main_connection_name
    "primary"
  end

  # run the block of code w/ a connection to another DB, given connection name
  def self.with_connection(name)
    original = ActiveRecord::Base.connection_specification_name

    if 'true' == ENV['PIO_MULTIPLE_DB']&.downcase
      ActiveRecord::Base.connection_specification_name = name.to_s
      yield
    else
      Rails.logger.warn "PioMultipleDb: multiple db not enabled, treat '#{name}' as '#{original}'"
      yield
    end
  ensure
    ActiveRecord::Base.connection_specification_name = original
  end

  # shortcut to run a block of code with readonly DB
  def self.with_readonly
    with_connection(readonly_connection_name) { yield }
  end

  # shortcut to run a block of code with main DB
  def self.with_main
    with_connection(main_connection_name) { yield }
  end
end
