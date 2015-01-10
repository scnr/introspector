require 'arachni/introspector'
require 'rack'
require 'stringio'
require 'rack/content_length'

class Rack::Handler::ArachniIntrospector

Rack::Handler.register :arachni_introspector, self

class Server
    def initialize( options = {}, &block )
        Arachni::HTTP::Client.service( options, &block )
    end

    def run
        sleep 0.5 while running?
    end

    def stop
        Arachni::HTTP::Client.remove_service
        true
    end

    def running?
        Arachni::HTTP::Client.has_service?
    end
end

class <<self

    # Starts the server and runs the `app`.
    #
    # @param  [#call] app
    #   Rack Application to run.
    # @param  [Hash]  options
    #   Rack options.
    def run( app, options = {} )
        return false if @server

        @options = options
        @options[:address]  = options[:Host] || default_host
        @options[:port]   ||= options[:Port] || 80

        @app    = app
        @server = Server.new( options ) do |response|
            service response
        end
        yield @server if block_given?
        @server.run

        true
    end

    def run_in_thread( *args, &block )
        return false if @thread || @server

        @thread = Thread.new do
            run( *args, &block )
            @thread = nil
        end

        sleep 0.1 while !running?

        true
    end

    def thread
        @thread
    end

    def running?
        @server && @server.running?
    end

    # Shuts down the server.
    def shutdown
        @thread.kill if @thread
        @thread = nil
        @server.stop if @server
        @server = nil
    end

    private

    def valid_options
        {
            'Host=HOST' => "Hostname to use (default: #{default_host})",
            'Port=PORT' => 'Port to use (default: 80)'
        }
    end

    def default_host
        (ENV['RACK_ENV'] || 'development') == 'development' ? 'localhost' : '0.0.0.0'
    end

    def service( response )
        request = response.request
        path    = request.parsed_url.path

        environment = {
            'REQUEST_METHOD'  => request.method.to_s.upcase,
            'SCRIPT_NAME'     => '',
            'PATH_INFO'       => path,
            'REQUEST_PATH'    => path,
            'QUERY_STRING'    => request.effective_parameters.
                map { |k, v| "#{Arachni::Link.encode(k)}=#{Arachni::Link.encode(v)}" }.join('&'),
            'SERVER_NAME'     => @options[:address],
            'SERVER_PORT'     => @options[:port].to_s,
            'HTTP_VERSION'    => 'HTTP/1.1',
            'REMOTE_ADDR'     => @options[:address]
        }

        request.headers.each do |k, v|
            environment["HTTP_#{k.upcase.gsub( '-', '_' )}"] = v
        end

        if environment['HTTP_CONTENT_TYPE']
            environment['CONTENT_TYPE'] = environment.delete( 'HTTP_CONTENT_TYPE' )
        end

        if environment['HTTP_CONTENT_LENGTH']
            environment['CONTENT_LENGTH'] = environment.delete( 'HTTP_CONTENT_LENGTH' )
        end

        environment['SERVER_PROTOCOL'] = environment['HTTP_VERSION']

        if request.body.is_a? Hash
            body = request.body.map { |k, v| "#{Arachni::Form.encode(k)}=#{Arachni::Form.encode(v)}" }.join('&')
        else
            body = Arachni::Form.encode(request.body.to_s)
        end
        request.effective_body = body

        rack_input = StringIO.new( body.to_s )
        rack_input.set_encoding( Encoding::BINARY ) if rack_input.respond_to?( :set_encoding )

        environment.update(
            'rack.version'      => Rack::VERSION,
            'rack.input'        => rack_input,
            'rack.errors'       => $stderr,
            'rack.multithread'  => false,
            'rack.multiprocess' => false,
            'rack.run_once'     => false,
            'rack.url_scheme'   => 'http',
            'rack.hijack?'      => false
        )

        body    = ''
        headers = {}
        begin
            app_call = proc { response.code, headers, body = @app.call( environment ) }

            if @options[:coverage] && @options[:coverage][:request]
                request.trace( @options[:coverage][:request], &app_call )
            else
                app_call.call
            end

            body = '' if !body

            if body.is_a? String
                response.body = body
            else
                body.each { |part| (response.body ||= '') << part }
            end

            response.headers.merge! headers
        rescue RuntimeError => e
            response.code = 501
            response.body = "#{e} (#{e.class})"

            environment['rack.errors'].puts response.body
            e.backtrace.each do |line|
                environment['rack.errors'].puts line
                response.body << "#{line}\n"
            end

            response.headers['content-type'] = 'text/plain'
        end
    ensure
        body.close if body.respond_to? :close
    end

end

end
