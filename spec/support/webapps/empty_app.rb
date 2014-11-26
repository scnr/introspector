require 'sinatra/base'

class EmptyApp < Sinatra::Base
    get '/' do
        ''
    end
end
