require 'sinatra/base'

begin
  require 'haml'
rescue LoadError
  raise "In order to use sinatra/security, make sure you have haml installed"
end

module Sinatra
  module Security
    autoload :Helpers, 'sinatra/security/helpers'
    
    def self.registered(app)
      app.helpers Helpers

      app.post '/login' do
        if authenticate(params)
          redirect_to_stored
        else
          session[:error] = "We are sorry: the information supplied is not valid."
          haml :login
        end
      end
    end
  end

  register Security
end
