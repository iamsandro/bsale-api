module Mysql2AdapterPatch
  def execute(*args)
    # During `reconnect!`, `Mysql2Adapter` first disconnect and set the
    # @connection to nil, and then tries to connect. When connect fails,
    # @connection will be left as nil value which will cause issues later.
    connect if @connection.nil?

    begin
      super(*args)
    rescue ActiveRecord::StatementInvalid => e
      if e.message =~ /server has gone away/i
        in_transaction = transaction_manager.current_transaction.open?
        try_reconnect
        in_transaction ? raise : retry
      else
        raise
      end
    end
  end

  private

  def try_reconnect
    sleep_times = [0.1, 0.5, 1, 2, 3, 4]

    begin
      reconnect!
    rescue Mysql2::Error => e
      sleep_time = sleep_times.shift
      if sleep_time && e.message =~ /can't connect/i
        warn "Server timed out, retrying in #{sleep_time} sec."
        sleep sleep_time
        retry
      else
        raise
      end
    end
  end
end

require "active_record/connection_adapters/mysql2_adapter"
ActiveRecord::ConnectionAdapters::Mysql2Adapter.prepend Mysql2AdapterPatch
