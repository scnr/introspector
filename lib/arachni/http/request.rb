module Arachni
module HTTP
class Request

    attr_accessor :coverage

    def run
        response = nil
        @on_complete = [proc{ |r| response = r }]

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
