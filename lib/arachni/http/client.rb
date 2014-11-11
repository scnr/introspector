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
        1
    end

    def max_concurrency
        1
    end

    private

    def client_initialize
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

        response = Response.new( url: request.url, request: request )
        response.redirections ||= []

        begin
            t = Time.now
            Timeout.timeout request.timeout do
                @service.call response
            end

            response.time = response.app_time = response.total_time = Time.now - t
        rescue Timeout::Error
            response.time = response.app_time = response.total_time = 0
            response.return_code = :operation_timedout
        end

        request.handle_response response

        false
    end

end
end
end
