require 'arachni/introspector/scan/coverage'
require 'rack/handler/arachni_introspector'

module Arachni
module Introspector

class Scan
    extend Forwardable

    class Error < Introspector::Error
        class Inactive < Error
        end

        class Dirty < Error
        end

        class StillRunning < Error
        end
    end

    UNLOAD_CHECKS  = [
        :backdoors, :backup_directories, :backup_files, :htaccess_limit,
        :localstart_asp, :webdav, :xst, :common_directories, :common_files
    ]

    UNLOAD_PLUGINS = [
        :autothrottle
    ]

    # @return   [Arachni::Framework]
    attr_reader :framework

    # @return   [#call]
    #   Rack application.
    attr_reader :application

    # @return   [Scan::Coverage]
    attr_reader :coverage

    # @param    [#call] application
    #   Rack application.
    # @param    [Hash]  options
    # @option  options  [String]    :host
    #   Hostname to use -- defaults to `app` name.
    # @option  options  [String]    :port   (80)
    #   Port number to use.
    # @option  options  [Hash]    :framework
    #   {Arachni::Framework} options for {Arachni::Options#update}.
    def initialize( application, options = {} )
        @application = application
        @options     = options.dup

        klass = @application

        if !@application.is_a?( Class ) && !@application.is_a?( Class )
            klass = klass.class
        end

        @host = @options[:host] || klass.to_s.downcase.gsub( '::', '-' )
        @port = @options[:port] || 80

        @options[:coverage] ||= {}

        if Scan::Coverage.enabled? && @options[:coverage]
            @coverage = Introspector::Scan::Coverage.new( @options[:coverage] )
        end

        set_options
        set_framework
    end

    # @param    [Arachni::Issue]    issue
    #   Issue to recheck.
    # @return   [Arachni::Issue,nil]
    #   Reproduced issue or `nil` if the issue couldn't be reproduced.
    #
    # @raise    [Error::StillRunning]
    #   If the scan is still running.
    def recheck_issue( issue )
        fail_if_still_running

        start_app

        @framework.checks.clear

        issue.recheck @framework
    ensure
        stop_app
    end

    # @note **Do not** forget to call {#clean_up} once you have finished
    #   working with the scan. You probably want to grab the {#report} and
    #   {#clean_up} right after. Alternatively, use one of the {Introspector}
    #   helper methods.
    #
    # Starts the scan.
    #
    # @raise    [Error::StillRunning]
    #   If the scan is running.
    # @raise    [Error::Dirty]
    #   If the scan has already been used.
    def start
        fail_if_still_running
        fail_if_dirty

        @active = true

        start_app

        @framework.run

        if @coverage
            @coverage.retrieve_results
        end

        nil
    ensure
        stop_app
    end

    # Starts the scan in a {#thread} and blocks until it starts.
    #
    # @param    [Block] block
    #   Block to be called and passed `self` at the end of the scan.
    #
    # @return   [Thread]
    #   Scan {#thread}.
    def start_in_thread( &block )
        fail_if_still_running
        fail_if_dirty

        @thread = Thread.new do
            start
            block.call( self ) if block_given?
            @thread = nil
        end

        sleep 0.1 while status == :ready
        @thread
    end

    # @return   [Thread,nil]
    #   Scan thread if {#start_in_thread} was used to start the scan and the
    #   scan hasn't yet finished.
    def thread
        @thread
    end

    # Signals the scan to abort and blocks until then.
    #
    # @raise    [Error::Inactive]
    def abort
        @framework.abort
        stop_app
    end

    # @note **Has** to be called after each scan is done.
    #
    # Cleans up the entire environment, unloading components and clearing
    # state and data.
    #
    # @raise    [Error::StillRunning]
    def clean_up
        fail_if_still_running

        @framework.clean_up
        @framework.reset
        stop_app
    end

    def report
        @framework.report.tap { |r| r.coverage = @coverage }
    end

    [:statistics, :status_messages, :sitemap, :status, :running?,
     :scanning?, :paused?, :pause?, :pausing?, :aborted?, :abort?, :aborting?,
     :suspend, :suspend?, :suspended?, :done?, :snapshot_path, :restore].each do |m|
        define_method m do |*args|
            @framework.send m, *args
        end
    end

    def pause
        @pause_id = @framework.pause( :introspector )
    end

    def resume
        @framework.resume @pause_id
    end

    private

    def fail_if_still_running
        fail Error::StillRunning if running? && status != :ready && status != :done
    end

    def fail_if_inactive
        fail Error::Inactive if !@active
    end

    def fail_if_dirty
        fail Error::Dirty if @active
    end

    def start_app
        Rack::Handler::ArachniIntrospector.run_in_thread @application, @options
    end

    def stop_app
        Rack::Handler::ArachniIntrospector.shutdown
    end

    def set_options
        path = @options[:path].to_s
        path = "/#{path}" if !path.start_with?( '/' )

        Options.update( @options.delete(:framework) || {} )

        Options.url               = "http://#{@host}:#{@port}#{path}"
        Options.no_fingerprinting = true
        Options.platforms        |= [Introspector.os, :rack, :ruby]

        # This affects things even though we've overriden the HTTP::Client
        # interface. For example, it's used by the HTTP::ProxyServer and needs
        # to be 1 because it's weirdly causing segfaults otherwise.
        #
        # Something to do with Threads, not sure what's going on there...
        Options.http.request_concurrency = 1
    end

    def set_framework
        @framework = Arachni::Framework.new

        @framework.checks.load Options.checks
        UNLOAD_CHECKS.each { |c| @framework.checks.unload c }

        @framework.plugins.load_defaults
        @framework.plugins.load Options.plugins.keys
        UNLOAD_PLUGINS.each { |c| @framework.plugins.unload c }

        @framework
    end

end

end
end
