require 'scnr/introspector/scan/coverage'
require 'rack/handler/scnr_introspector'

module SCNR
module Introspector

class Scan
    extend Forwardable

    class Error < Introspector::Error
        class StillRunning < Error
        end

        class CleanedUp < Error
        end
    end

    UNLOAD_CHECKS  = [
        :backdoors, :backup_directories, :backup_files, :htaccess_limit,
        :localstart_asp, :webdav, :xst, :common_directories, :common_files
    ]

    UNLOAD_PLUGINS = [
        :autothrottle
    ]

    # @return   [SCNR::Framework]
    attr_reader :scanner

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
    # @option  options  [Hash]    :scanner
    #   {SCNR::Engine} options for {SCNR::Engine::Options#update}.
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
            @coverage = Scan::Coverage.new( @options[:coverage] )
        end

        set_options
        set_framework
    end

    # @param    [SCNR::Issue]    issue
    #   Issue to recheck.
    # @return   [SCNR::Issue,nil]
    #   Reproduced issue or `nil` if the issue couldn't be reproduced.
    #
    # @raise    [Error::StillRunning]
    #   If the scan is still running.
    def recheck_issue( issue )
        fail_if_running

        start_app

        @scanner.checks.clear

        i = issue.recheck

        stop_app

        i
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
    def start
        fail_if_running

        @active = true

        start_app

        @scanner.run
        @active = false

        if @coverage
            @coverage.retrieve_results
        end

        stop_app

        nil
    end

    # Starts the scan in a {#thread} and blocks until it starts.
    #
    # @param    [Block] block
    #   Block to be called and passed `self` at the end of the scan.
    #
    # @return   [Thread]
    #   Scan {#thread}.
    def start_in_thread( &block )
        fail_if_running

        @thread = Thread.new do
            start
            block.call( self ) if block_given?
            @thread = nil
        end

        sleep 0.1 while status == :running
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
        @scanner.abort!
        stop_app
    end

    # @note **Has** to be called after each scan is done.
    #
    # Cleans up the entire environment, unloading components and clearing
    # state and data.
    #
    # @raise    [Error::StillRunning]
    def clean_up
        return if @cleaned_up
        @cleaned_up = true

        fail_if_running

        @scanner.clean_up
        @scanner.reset
        stop_app
    end

    # @return   [SCNR::Engine::Report]
    #
    # @raise    [Error::CleanedUp]
    #   If {#clean_up} has already been called.
    def report
        fail Error::CleanedUp, 'Cannot retrieve report for a #cleaned_up scan.' if @cleaned_up

        @scanner.report.tap { |r| r.coverage = @coverage }
    end

    [:statistics, :status_messages, :sitemap, :status, :running?,
     :scanning?, :paused?, :pause?, :pausing?, :aborted?, :abort?, :aborting?,
     :suspend, :suspend?, :suspended?, :done?, :snapshot_path, :restore].each do |m|
        define_method m do |*args|
            @scanner.send m, *args
        end
    end

    def pause
        @scanner.pause!
    end

    def resume
        @scanner.resume!
    end

    private

    def fail_if_running
        fail Error::StillRunning if @active
    end

    def start_app
        Rack::Handler::SCNRIntrospector.run_in_thread @application, @options
    end

    def stop_app
        Rack::Handler::SCNRIntrospector.shutdown
    end

    def set_options
        path = @options[:path].to_s
        path = "/#{path}" if !path.start_with?( '/' )

        self.class.reset_options
        Engine::Options.update( @options.delete(:scanner) || {} )

        Engine::Options.url        = "http://#{@host}:#{@port}#{path}"
        Engine::Options.platforms |= [Introspector.os, :rack, :ruby]
    end

    class <<self

        # Resets the {SCNR::Options} to values
        def reset_options
            Engine::Options.reset
            Engine::Options.do_not_fingerprint

            # This affects things even though we've overridden the HTTP::Client
            # interface. For example, it's used by the HTTP::ProxyServer.
            #
            # Also, it's good to give the Framework a heads-up.
            Engine::Options.http.request_concurrency = 1
            Engine::Options.http.request_queue_size  = 1

            # Don't use a timeout by default because we've got to use
            # Timeout.timeout for that which has a considerable overhead.
            Engine::Options.http.request_timeout = -1
        end
    end

    def set_framework
        @scanner = Engine::Framework.unsafe

        @scanner.checks.load Engine::Options.checks
        UNLOAD_CHECKS.each { |c| @scanner.checks.unload c }

        @scanner.plugins.load_defaults
        @scanner.plugins.load Engine::Options.plugins.keys
        UNLOAD_PLUGINS.each { |c| @scanner.plugins.unload c }

        @scanner
    end

end

end
end
