module Arachni
module Introspector

class Scan
    extend Forwardable

    class Error < Arachni::Error
        class Inactive < Error
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
    ] + UNLOAD_CHECKS.map { |s| "-#{s}" }

    DEFAULT_ELEMENTS = [
        :links, :forms, :cookies
    ]

    attr_reader :framework
    attr_reader :app

    def initialize( app, options = {}, &block )
        @app     = app
        @options = options

        @host = @options[:host] || @app.to_s.downcase.gsub( '::', '-' )
        @port = @options[:port] || 80

        set_framework_options( @options.delete(:framework) || {} )

        start( &block ) if block_given?
    end

    def start( &block )
        return false if @framework

        start_app

        if block_given?
            Arachni::Framework.new do |f|
                configure_framework( f ).run
                block.call self
            end
        else
            configure_framework( Arachni::Framework.new ).run
        end

        true
    ensure
        stop_app
    end

    def start_in_thread
        return if @framework

        @thread = Thread.new do
            start
            @thread = nil
        end

        sleep 0.1 while !@framework
        @thread
    end

    def thread
        @thread
    end

    def abort
        fail Error::Inactive if !@framework

        @framework.abort
        stop_app
    end

    def clean_up
        fail Error::Inactive if !@framework

        @framework.reset
        stop_app
    end

    [:report, :statistics, :status_messages, :sitemap, :status, :running?,
     :scanning?, :paused?, :pause?, :pausing?, :aborted?,
     :abort?, :aborting?, :suspend, :suspend?, :suspended?, :snapshot_path,
     :restore].each do |m|
        define_method m do |*args|
            fail Error::Inactive if !@framework
            @framework.send m, *args
        end
    end

    def pause
        fail Error::Inactive if !@framework
        @framework.pause :introspector
    end

    def resume
        fail Error::Inactive if !@framework
        @framework.resume :introspector
    end

    def issues
        fail Error::Inactive if !@framework
        return {} if report.issues.empty?
        report.issues
    end

    private

    def start_app
        Rack::Handler::ArachniIntrospector.run_in_thread @app, @options
    end

    def stop_app
        Rack::Handler::ArachniIntrospector.shutdown
    end

    def set_framework_options( options )
        path = @options[:path].to_s
        path = "/#{path}" if !path.start_with?( '/' )

        @checks  = options.delete(:checks)   || DEFAULT_CHECKS
        @plugins = options.delete(:plugins)  || []

        Options.update options

        Options.url              ||= "http://#{@host}:#{@port}#{path}"
        Options.no_fingerprinting  = true
        Options.platforms         |= [Introspector.os, :rack, :ruby]

        if !Options.audit.links? && !Options.audit.forms? ||
            !Options.audit.cookies? || !Options.audit.headers?
            Options.audit.elements DEFAULT_ELEMENTS
        end
    end

    def configure_framework( f )
        f.checks.load @checks
        UNLOAD_CHECKS.each { |c| f.checks.unload c }

        f.plugins.load_defaults
        f.plugins.load @plugins
        UNLOAD_PLUGINS.each { |c| f.plugins.unload c }

        @framework = f
    end

end

end
end
