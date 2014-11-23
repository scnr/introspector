require 'rbconfig'
require 'arachni'

module Arachni
module Introspector

require 'arachni/introspector/version'
require 'arachni/introspector/error'
require 'arachni/introspector/coverage'
require 'arachni/introspector/scan'
require 'arachni/introspector/patches/http/client'
require 'arachni/introspector/patches/http/request'

class<<self

    # {Scan#start Runs} a {Scan scan}.
    #
    # @param    (see Scan#initialize)
    # @param    [Block] block
    #   If a block is given, it will be passed the {Scan scan} object
    #   once the scan completes and then {Scan#clean_up clean-up} the
    #   environment.
    #
    # @return   [Scan, Object]
    #   The completed scan, or the return value of the `block`, if one was
    #   given.
    def scan( *args, &block )
        s = Scan.new( *args )
        s.start

        if block_given?
            r = nil
            begin
                r = block.call( s )
            ensure
                s.clean_up
            end

            return r
        end

        s
    end

    # {Scan#start_in_thread Runs} a {Scan scan} in its own {Scan#thread thread}.
    #
    # @param    (see Scan#initialize)
    # @param    (see Scan#start_in_thread)
    #
    # @return   [Scan]
    #   The running scan object.
    def scan_in_thread( *args, &block )
        s = Scan.new( *args )
        s.start_in_thread(&block)
        s
    end

    # {Scan#start Runs} a {Scan scan}, returns the {Scan#report report} and
    # {Scan#clean_up cleans-up} the environment.
    #
    # @param    (see Scan#initialize)
    #
    # @return   [Arachni::Report]
    #   Report for the completed scan.
    def scan_and_report( *args )
        s = Scan.new( *args )
        s.start
        s.report
    ensure
        s.clean_up
    end

    # {Scan#start Runs} a {Scan scan}, returns the {Scan#report report} and
    # {Scan#clean_up cleans-up} the environment.
    #
    # @param    [#call] app
    #   Rack-app.
    # @param    [Arachni::Issue] issue
    #   Issue to recheck.
    # @param    [Hash] options
    #   {Scan} {Scan#initialize options}.
    #
    # @return   (see Scan#recheck_issue)
    def recheck_issue( app, issue, options = {} )
        Scan.new( app, options ).recheck_issue( issue )
    end

    # @return   [Symbol]
    #   {Arachni::Platform::Manager::OS OS platform type} to use for
    #   {Arachni::Options#platforms}.
    def os
        @os ||= (
            host_os = RbConfig::CONFIG['host_os']

            case host_os
                when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                    :windows

                when /linux/
                    :linux

                when /darwin|mac os|bsd/
                    :bsd

                when /solaris/
                    :solaris

                else
                    fail Arachni::Platform::Error::Invalid, "Unknown OS: #{host_os}"
            end
        )
    end

    # @private
    def clear_os_cache
        @os = nil
    end

end

end
end
