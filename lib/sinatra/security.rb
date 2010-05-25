require 'sinatra/base'

module Sinatra
  module Security
    autoload :Helpers,        'sinatra/security/helpers'
    autoload :User,           'sinatra/security/user'
    autoload :Validations,    'sinatra/security/validations'
    autoload :Password,       'sinatra/security/password'
    autoload :Identification, 'sinatra/security/identification'
    autoload :LoginField,     'sinatra/security/login_field'

    def self.registered(app)
      app.helpers Helpers
      app.set :login_error_message, "Wrong Email and/or Password combination."
      app.set :login_url,           "/login"
      app.set :login_user_class,    :User
      app.set :ignored_by_return_to, /(jpe?g|png|gif|css|js)$/
        
      app.post '/login' do
        if authenticate(params)
          redirect_to_return_url
        else
          session[:error] = settings.login_error_message
          redirect settings.login_url
        end
      end
    end
  end

  register Security
end
