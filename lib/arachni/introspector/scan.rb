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
        :localstart_asp, :webdav, :xst
    ]

    UNLOAD_PLUGINS = [
        :autothrottle
    ]

    DEFAULT_CHECKS = [
        '*'
    ]

    DEFAULT_ELEMENTS = [
        :links, :forms, :cookies
    ]

    # @return   [Arachni::Framework]
    attr_reader :framework

    # @return   [#call]
    #   Rack app.
    attr_reader :app

    # @param    [#call] app
    #   Rack app.
    # @param    [Hash]  options
    # @option  options  [String]    :host
    #   Hostname to use -- defaults to `app` name.
    # @option  options  [String]    :port   (80)
    #   Port number to use.
    # @option  options  [Hash]    :framework
    #   {Arachni::Framework} options for {Arachni::Options#update}.
    def initialize( app, options = {} )
        @app     = app
        @options = options.dup

        @host = @options[:host] || @app.to_s.downcase.gsub( '::', '-' )
        @port = @options[:port] || 80

        set_options
        set_framework
    end

    # @param    [Arachni::Issue]    issue
    #   Issue to recheck.
    # @return   [Arachni::Issue]
    #   Reproduced issue.
    def recheck_issue( issue )
        start_app
        issue.recheck
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
    # @raise    [Error::Dirty]
    #   If the scan has already been used.
    def start
        fail_if_still_running
        fail_if_dirty

        @active = true

        start_app

        @framework.run
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
        fail_if_dirty

        @thread = Thread.new do
            start
            block.call( self ) if block_given?
            @thread = nil
        end

        sleep 0.1 while !running?
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

        @framework.reset
        stop_app
    end

    [:report, :statistics, :status_messages, :sitemap, :status, :running?,
     :scanning?, :paused?, :pause?, :pausing?, :aborted?, :abort?, :aborting?,
     :suspend, :suspend?, :suspended?, :snapshot_path, :restore].each do |m|
        define_method m do |*args|
            @framework.send m, *args
        end
    end

    def pause
        @framework.pause :introspector
    end

    def resume
        @framework.resume :introspector
    end

    private

    def fail_if_still_running
        fail Error::StillRunning if running?
    end

    def fail_if_inactive
        fail Error::Inactive if !@active
    end

    def fail_if_dirty
        fail Error::Dirty if @active
    end

    def start_app
        Rack::Handler::ArachniIntrospector.run_in_thread @app, @options
    end

    def stop_app
        Rack::Handler::ArachniIntrospector.shutdown
    end

    def set_options
        path = @options[:path].to_s
        path = "/#{path}" if !path.start_with?( '/' )

        options             = @options.delete(:framework) || {}
        options[:checks]  ||= DEFAULT_CHECKS
        options[:plugins] ||= {}

        Options.update options

        Options.url               = "http://#{@host}:#{@port}#{path}"
        Options.no_fingerprinting = true
        Options.platforms         |= [Introspector.os, :rack, :ruby]

        if !Options.audit.links? && !Options.audit.forms? ||
            !Options.audit.cookies? || !Options.audit.headers?
            Options.audit.elements DEFAULT_ELEMENTS
        end
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
