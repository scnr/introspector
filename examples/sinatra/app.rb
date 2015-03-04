require 'sinatra/base'

class MyApp < Sinatra::Base

    def noop
    end

    def process_params( params )
        noop
        params.values.join( ' ' )
    end

    get '/' do
        @instance_variable = {
            blah: 'foo'
        }
        local_variable = 1

        <<EOHTML
#{process_params( params )}
        <a href="?v=stuff">XSS</a>
EOHTML
    end

end
