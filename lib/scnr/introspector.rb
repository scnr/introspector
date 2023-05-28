require 'rbconfig'
require 'rack/utils'
require 'pp'

module SCNR
class Introspector
    include Rack::Utils

    require 'scnr/introspector/version'
    require 'scnr/introspector/error'
    require 'scnr/introspector/configuration'
    require 'scnr/introspector/scope'
    require 'scnr/introspector/trace'
    require 'scnr/introspector/coverage'

    Coverage.enable

    class <<self
        def trace
            @trace ||= {}
        end

        def trace=( t )
            @trace = t
        end

        def trace_to_json
            JSON.pretty_generate trace.inject( {} ) { |h, (k, v)| h[k] = v.to_rpc_data; h }
        end
    end

    def initialize( app, options = {} )
        @app     = app
        @options = options
    end

    def call( env )
        if id = env['HTTP_SCNR_INTROSPECTOR_TRACE']
            response = nil
            self.class.trace[id] = Trace.new @options do
                response = @app.call( env )
            end
            response
        elsif r = serve( env )
            r
        else
            @app.call( env )
        end

    rescue => e
        pp e
        pp e.backtrace
    end

    def serve( env )
        body = nil

        case env['REQUEST_PATH']
        when '/scnr/introspector/trace'
            params = {}
            if q = env['QUERY_STRING']
                params = parse_query( q )
            end

            if params['id']
                body = JSON.pretty_generate( self.class.trace[params['id']].to_rpc_data )
            else
                body = self.class.trace_to_json
            end

        when '/scnr/introspector/trace/clear'
            self.class.trace.clear

        when '/scnr/introspector/coverage'

        when '/scnr/introspector/platforms'
            platforms = [:ruby, os, db]
            if rails?
                platforms << :rails
            end

            body = JSON.pretty_generate( platforms.compact )

        else
            return nil
        end

        [200, { 'Content-Type' => 'application.json' }, [body.to_s]]
    end

    # @return   [Symbol]
    #   {SCNR::Platform::Manager::OS OS platform type} to use for
    #   {SCNR::Options#platforms}.
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
                    nil
            end
        )
    end

    def db
        return if !rails?

        case ActiveRecord::Base.connection.adapter_name
        when 'PostgreSQL'
            :pgsql

        when 'MySQL'
            :mysql

        when 'SQLite3'
            :sqlite

        else
            nil

        end
    end

    def rails?
        if defined? Rails
            return @app.is_a? Rails::Application
        end
    end

end
end
