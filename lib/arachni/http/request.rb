module Arachni
module HTTP
class Request

    def run
        response = nil
        @on_complete = [proc{ |r| response = r }]

        @mode = :async
        Client.queue self
        @mode = :sync

        response
    end

end
end
end

