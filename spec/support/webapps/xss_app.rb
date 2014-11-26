require 'sinatra/base'

class XssApp < Sinatra::Base

    def process_params( params )
        params.values.join( ' ' )
    end

    get '/' do
        n = 1
        s = <<EOHTML
            #{process_params( params )}
            <a href="?v=stuff">XSS</a>
EOHTML
        n = 2
        s
    end
end
