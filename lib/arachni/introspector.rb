require 'rbconfig'
require 'arachni'

module Arachni
module Introspector

    require 'arachni/introspector/version'
    require 'arachni/introspector/error'
    require 'arachni/introspector/coverage'
    require 'arachni/introspector/scan'
    require_relative 'http/client'
    require_relative 'http/request'

    class<<self

        def scan( *args, &block )
            s = Scan.new( *args, &block )
            s.start
            s
        end

        def scan_in_thread( *args, &block )
            s = Scan.new( *args, &block )
            s.start_in_thread
            s
        end

        def scan_and_report( *args )
            report = nil
            Scan.new( *args ) { |s| report = s.report }
            report
        end

        def recheck_issue( app, issue, options = {} )
            Scan.new( app, options ).recheck_issue( issue )
        end

        def os
            @os ||= (
                host_os = RbConfig::CONFIG['host_os']
                case host_os
                    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                        :windows
                    when /darwin|mac os/
                        :macosx
                    when /linux/
                        :linux
                    when /bsd/
                        :bsd
                    when /solaris/
                        :solaris
                    else
                        fail "Unknown OS: #{host_os}"
                end
            )
        end

    end

end
end
