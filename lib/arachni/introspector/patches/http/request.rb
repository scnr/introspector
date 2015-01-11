require 'base64'
require 'arachni/introspector/patches/http/request/trace'

module Arachni
module HTTP
class Request

    # @return   [nil,Trace]
    #   Trace for this request or `nil` if tracing has not been enabled.
    attr_accessor :trace

    alias :old_prepare_headers :prepare_headers

    # Traces a `block` and sets {#trace}.
    #
    # @param    [Hash]  options
    #   {Trace} options.
    # @param    [Block] block
    #   Block to trace.
    def with_trace( options = {}, &block )
        @trace = Trace.new( options, &block )
    end

    def prepare_headers
        old_prepare_headers

        if (user = (@username || Options.http.authentication_username))
            if (pass = (@password || Options.http.authentication_password))
                userpass = Base64.encode64( "#{user}:#{pass}" )
                headers['Authorization'] = "Basic #{userpass}"
            end
        end
    end

    def run
        response = nil
        @on_complete << proc{ |r| response = r }

        @mode = :async
        Client.queue self
        @mode = :sync

        response
    end

    alias :old_to_h :to_h
    def to_h
        old_to_h.merge( trace: trace )
    end

end
end
end
