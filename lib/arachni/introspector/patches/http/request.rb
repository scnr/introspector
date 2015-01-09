require 'base64'
require 'arachni/introspector/patches/http/request/coverage'

module Arachni
module HTTP
class Request

    attr_accessor :coverage

    alias :old_prepare_headers :prepare_headers

    def trace( options = {}, &block )
        @coverage = Coverage.new( options, &block )
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

    def to_h
        super.merge( coverage: coverage )
    end

end
end
end
