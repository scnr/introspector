require 'rbconfig'
require 'arachni'

module Arachni
module Introspector

require 'arachni/introspector/version'
require 'arachni/introspector/error'
require 'arachni/introspector/configuration'
require 'arachni/introspector/scan'
require 'arachni/introspector/patches/report'
require 'arachni/introspector/patches/http/client'
require 'arachni/introspector/patches/http/request'
require 'arachni/introspector/patches/issue'

class<<self

    # @note If not set, it will be {#detect_application auto-detected}.
    #
    # @return   [Class]
    #   Web application to be scanned
    attr_accessor :application

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
    def scan( options = {}, &block )
        s = Scan.new( target_application, options )
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
    def scan_in_thread( options = {}, &block )
        s = Scan.new( target_application, options )
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
    def scan_and_report( options = {} )
        s = Scan.new( target_application, options )
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
    def recheck_issue( issue, options = {} )
        s = Scan.new( target_application, options )
        s.recheck_issue( issue )
    ensure
        s.clean_up
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

    def target_application
        @application || detect_application
    end

    def detect_application
        return @detected_application if @detected_application

        if defined?( Rails ) && Rails.application
            return @detected_application = Rails.application
        end

        if defined?( Sinatra )
            ObjectSpace.each_object( Class ).select do |klass|
                next if !(klass < Sinatra::Base) || klass == Sinatra::Application
                return @detected_application = klass
            end
        end

        nil
    end

    # Include the {Arachni::UI::CLI}'s {Arachni::UI::Output} interface
    # to show scan messages.
    def enable_output
        @with_output_interface ||= Gem::Specification.each do |spec|
            next if spec.name != 'arachni'
            require "#{spec.gem_dir}/ui/cli/output"
            break
        end

        Arachni::UI::Output.unmute
    end

    # Mutes the {Arachni::UI::Output} interface.
    #
    # @see #enable_output
    def disable_output
        Arachni::UI::Output.mute
    end

    # @private
    def clear_os_cache
        @os = nil
    end

end

end
end
