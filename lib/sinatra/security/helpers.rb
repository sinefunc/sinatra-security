module Sinatra
  module Security
    module Helpers
      # The main gateway. This method will redirect if no user is currently
      # authenticated. 
      #
      # @example
      #
      #   get '/secured' do
      #     require_login
      #
      #     # do super private thing here
      #   end
      #
      # @param [String] login_url (defaults to /login) the url of the login form.
      #                 take not that even if you specify a different login form,
      #                 the POST action for that form should still be '/login'.
      def require_login(login_url = settings.login_url)
        return if logged_in?

        if should_return_to?(request.fullpath)
          session[:return_to] = request.fullpath
        end
        redirect login_url
      end
  
      # Dynamic redirection based on the return path that was set.
      #
      # @example
      #   
      #   # By default assumes you use :return_to and '/'.
      #   # You can use this in your code as well. i.e.
      #   get '/fb/login' do
      #     session[:fb_return_to] = params[:from]
      #     # redirect to fb OAuth URI here.
      #   end
      #
      #   get '/fb/success' do
      #     # successfully processed, save whatever here
      #     redirect_to_return_url :fb_return_to, "/home"
      #   end
      #
      # @param [Symbol] session_key the key in the session, defaults to
      #                 :return_to.
      # @param [String] default url when no stored value is found in
      #                 session[session_key]. defaults to '/'.
      def redirect_to_return_url(session_key = :return_to, default = '/')
        redirect session.delete(:return_to) || default
      end
      
      # Returns the currently logged in user, identified through 
      # session[:user]. The default finder uses User[id], based on Ohm's
      # finder method.
      #
      # @see http://ohm.keyvalue.org
      #
      # @example
      #   
      #   # ActiveRecord style finders
      #   current_user(lambda { |id| User.find(id) })
      #
      #   # Also, if you change the settings to use a different user class,
      #   # then that will be respected
      #   set :login_user_class, :SuperUser
      #
      #   # assuming session[:user] == 1
      #   current_user == SuperUser[1]
      #   # => true
      #
      # @param [Proc] finder (defaults to User[id]) allows you to pass in a
      #               different finder method. 
      # @return [User] or alternatively, an instance of settings.login_user_class
      def current_user(finder = lambda { |id| __USER__[id] })
        @current_user ||= finder.call(session[:user]) if session[:user]
      end
      
      # @return [true] if the user is logged in
      # @return [false] if the user is not logged in
      def logged_in?
        !! current_user
      end
    
      # Used for simple atomic authorization rules on a per action / route 
      # basis. 
      #
      # @example
      #
      #   get '/posts/:id/edit' do |id|
      #     post = Post[id]
      #     ensure_current_user post.author # halts to a 404 if not satisfied.
      #
      #     # the rest of this gets executed when 
      #     # the author is indeed the current user.
      #   end
      #
      # @param [User] a user object.
      def ensure_current_user(user)
        halt 404 unless user == current_user
      end
  
      # The method says it all. Mostly for keeping responsibility where it 
      # belongs, instead of letting the application code deal with the session
      # keys themselves.
      def logout!
        session.delete(:user) 
      end
     
      # Internally used by the POST /login route handler.
      #
      # @param [Hash] opts The hash containing :username and :password.
      # @option opts [#to_s] :username The username of a User.
      # @option opts [String] :password The password of a User.
      # @return [String] the `id` of the user if found.
      # @return [nil] if no user matches the :username / :password combination.
      def authenticate(opts)
        if user = __USER__.authenticate(opts[:username], opts[:password])
          session[:user] = user.id
        end
      end

      # @private transforms settings.login_user_class to a constant, 
      #          and used by current_user
      def __USER__
        Object.const_get(settings.login_user_class)
      end
  
      # @private internally used by Sinatra::Security::Helpers#require_login
      def should_return_to?(path, ignored = settings.ignored_by_return_to)
        !(path =~ ignored)
      end
    end
  end
end
