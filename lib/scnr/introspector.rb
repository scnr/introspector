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

    # Coverage.enable

    def initialize( app, options = {} )
        @app     = app
        @options = options

        @mutex = Mutex.new
    end

    def synchronize( &block )
        @mutex.synchronize( &block )
    end

    def call( env )
        info = Set.new
        info << :platforms

        if env['HTTP_X_SCNR_INTROSPECTOR_TRACE']
            info << :trace
        end

        inject( env, info )
    end

    def inject( env, info = [] )
        data = {}

        response = nil
        if info.include? :trace

            trace = nil
            synchronize do
                trace = Trace.new @options do
                    response = @app.call( env )
                end
            end

            data['trace'] = trace.to_rpc_data
        else
            response = @app.call( env )
        end

        if info.include? :platforms
            data['platforms'] = self.platforms
        end

        if info.include?( :coverage ) && Coverage.enabled?
            data['coverage'] = Coverage.new( @options ).retrieve_results
        end

        code    = response.shift
        headers = response.shift
        body    = response.shift

        seed = env['HTTP_X_SCNR_ENGINE_SCAN_SEED']

        body << "<!-- #{seed}\n#{JSON.dump( data )}\n -->"
        headers['Content-Length'] = body.map(&:bytesize).inject(&:+)

        [code, headers, body]
    end

    def platforms
        platforms = [:ruby, os, db]
        if rails?
            platforms << :rails
        end
        platforms.compact
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
