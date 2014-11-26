require 'zlib'
require 'stringio'

module Arachni
module HTTP
class Client

    class Error
        class MissingServiceHandler < Error
        end
    end

    def service( options = {}, &block )
        @service = block
    end

    def has_service?
        !!@service
    end

    def remove_service
        @service = nil
    end

    def max_concurrency=( c )
        @max_concurrency = c
    end

    def max_concurrency
        @max_concurrency
    end

    private

    def client_initialize
        @max_concurrency = Options.http.request_concurrency
        true
    end

    def client_run
        true
    end

    def client_abort
        true
    end

    def client_queue( request )
        fail Error::MissingServiceHandler, 'Missing service handler.' if !@service

        original_request = request
        redirects        = 0
        while (response = run_request( request )).redirect? &&
            request.follow_location? &&
            (original_request.max_redirects && redirects < original_request.max_redirects) do

            request = Request.new(
                url: [response.headers.location].flatten.first,
                follow_location: true
            )
            redirects += 1
        end

        original_request.handle_response response

        false
    end

    def run_request( request )
        response = Response.new( url: request.url, request: request )
        response.redirections ||= []

        request.prepare_headers

        # Hate this, Timeout.timeout uses a thread which introduces a noticeable
        # overhead.
        begin
            t = Time.now
            Timeout.timeout request.timeout.to_i / 1_000.0 do
                @service.call response
            end

            response.time = response.app_time = response.total_time = Time.now - t
        rescue Timeout::Error
            response.time = response.app_time = response.total_time = 0
            response.return_code = :operation_timedout
        end

        response_max_size = Options.http.response_max_size || request.response_max_size
        if response_max_size && response.body.size > response_max_size
            response.body = ''
        end

        case response.headers['content-encoding'].to_s.downcase
            when 'gzip', 'x-gzip'
                response.body = unzip( response.body )
            when 'deflate', 'compress', 'x-compress'
                response.body = inflate( response.body )
        end

        if response.headers.delete( 'content-encoding' )
            response.headers['content-length'] = response.body.size
        end

        response
    end

    # @param    [String]    str
    #   Inflates `str`.
    #
    # @return   [String]
    #   Inflated `str`.
    def inflate( str )
        z = Zlib::Inflate.new
        s = z.inflate( str )
        z.close
        s
    end

    # @param    [String]    str
    #   Unzips `str`.
    #
    # @return   [String]
    #   Unziped `str`.
    def unzip( str )
        s = ''
        s.force_encoding( 'ASCII-8BIT' ) if s.respond_to?( :encoding )
        gz = Zlib::GzipReader.new( StringIO.new( str, 'rb' ) )
        s << gz.read
        gz.close
        s
    end

end
end
end
