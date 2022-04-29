# require "mysql2"
# # increase timeout so mysql server doesn't disconnect us
# wait_timeout = @config[:wait_timeout]
# wait_timeout = 2_592_000 unless wait_timeout.is_a?(Fixnum)
# variable_assignments << "@@wait_timeout = #{wait_timeout}"

# execute("SET #{variable_assignments.join(', ')}", :skip_logging)
