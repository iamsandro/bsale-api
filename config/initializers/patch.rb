# require "active_record/connection_adapters/mysql2_adapter"

# module Mysql2AdapterPatch
#   # increase timeout so mysql server doesn't disconnect us
#   pp "**************************************"
#   pp config
#   pp "**************************************"
#   wait_timeout = @config[:wait_timeout]
#   wait_timeout = 2_592_000 unless wait_timeout.is_a?(Integer)
#   variable_assignments << "@@wait_timeout = #{wait_timeout}"

#   execute("SET #{variable_assignments.join(', ')}", :skip_logging)
# end

# ActiveRecord::ConnectionAdapters::Mysql2Adapter.prepend Mysql2AdapterPatch
