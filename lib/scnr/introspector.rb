require 'rbconfig'
require 'rack/utils'
require 'pp'

module SCNR
class Introspector
    include Rack::Utils

    require 'scnr/introspector/version'
    require 'scnr/introspector/error'
    require 'scnr/introspector/scope'
    require 'scnr/introspector/execution_flow'
    require 'scnr/introspector/data_flow'
    require 'scnr/introspector/coverage'

    # Coverage.enable

    OVERLOAD = [
      [:erb, :Templates],
      [:test, [:SCNR, :Introspector, :Test]]
    ]

    module Overloads
    end

    OVERLOAD.each do |m, object|
        if object.is_a? Array
            name      = object.pop
            namespace = Object

            n = false
            object.each do |o|
                begin
                    namespace = namespace.const_get( o )
                rescue
                    n = true
                    break
                end
            end
            next if n

            object = namespace.const_get( name ) rescue next
        else
            object = Object.const_get( object ) rescue next
        end

        overload( object, m )
    end

    @mutex  = Mutex.new
    class <<self
        def overload( object, m )
            method_source_location = object.allocate.method(m).source_location

            ov = <<EORUBY
        module Overloads
        module #{object.to_s.split( '::' ).join}Overload
            def #{m}( *args )
                SCNR::Introspector.find_and_log_taint( #{object}, :#{m}, #{method_source_location.inspect}, args )
                super *args
            end
        end
        end

        #{object}.prepend Overloads::#{object.to_s.split( '::' ).join}Overload
EORUBY
            eval ov
        end

        def taint_seed=( t )
            @taint = t
        end

        def taint_seed
            @taint
        end

        def data_flows
            @data_flows ||= {}
        end

        def synchronize( &block )
            @mutex.synchronize( &block )
        end

        def log_sinks( taint, sink )
            synchronize do
                (self.data_flows[taint] ||= DataFlow.new).sinks << sink
            end
        end

        def filter_caller( a )
            dir = File.dirname( __FILE__ )
            a.reject do |c|
                c.start_with?( dir ) || c.include?( 'trace_point' )
            end
        end

        def find_and_log_taint( object, method, method_source_location, args )
            taint = @taint
            return if !taint

            tainted = find_taint_in_arguments( taint, args )
            return if !tainted

            sink = DataFlow::Sink.new(
              object:       object.to_s,
              method_name:  method.to_s,
              arguments:    args,
              tainted_argument_index: tainted[0],
              tainted_value:          tainted[1].to_s,
              backtrace:    filter_caller( Kernel.caller[1..-1] ),
              method_source_location: method_source_location
            )
            log_sinks( taint, sink )
        end

        def find_taint_in_arguments( taint, args )
            args.each.with_index do |arg, i|
                value = find_taint_recursively( taint, arg, i )
                next if !value

                return [i, value]
            end

            nil
        end

        def find_taint_recursively( taint, object, depth )
            case object
            when Hash
                object.each do |k, v|
                    t = find_taint_recursively( taint, v, depth )
                    return t if t
                end

            when Array
                object.each do |v|
                    t = find_taint_recursively( taint, v, depth )
                    return t if t
                end

            when String
                return object if object.include? taint

            else
                nil
            end

            nil
        end
    end

    def initialize( app, options = {} )
        @app     = app
        @options = options

        overload_application

        @mutex = Mutex.new
    end

    def overload_application
        @app.methods.each do |m|
            next if @app.method( m ).parameters.empty?
            self.class.overload( @app.class, m )
        end
    end

    def synchronize( &block )
        @mutex.synchronize( &block )
    end

    def call( env )
        info = Set.new
        info << :platforms

        if env.delete( 'HTTP_X_SCNR_INTROSPECTOR_TRACE' )
            info << :data_flow
            info << :execution_flow
        end

        inject( env, info )

    rescue => e
        pp e
        pp e.backtrace
    end

    def inject( env, info = [] )
        self.class.taint_seed = env.delete( 'HTTP_X_SCNR_INTROSPECTOR_TAINT' )
        seed                  = env.delete( 'HTTP_X_SCNR_ENGINE_SCAN_SEED' )

        data = {}

        response = nil
        if info.include? :execution_flow

            execution_flow = nil
            synchronize do
                execution_flow = ExecutionFlow.new @options do
                    response = @app.call( env )
                end
            end

            data['execution_flow'] = execution_flow.to_rpc_data
        else
            response = @app.call( env )
        end

        if info.include? :platforms
            data['platforms'] = self.platforms
        end

        if info.include?( :coverage ) && Coverage.enabled?
            data['coverage'] = Coverage.new( @options ).retrieve_results
        end

        if info.include?( :data_flow ) && self.class.taint_seed
            data['data_flow'] = self.class.data_flows.delete( self.class.taint_seed )&.to_rpc_data
        end

        code    = response.shift
        headers = response.shift
        body    = response.shift

        body << "<!-- #{seed}\n#{JSON.dump( data )}\n#{seed} -->"
        headers['Content-Length'] = body.map(&:bytesize).inject(&:+)

        [code, headers, body ]
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
