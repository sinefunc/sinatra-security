module Sinatra
  module Security
    # The identification module is mixed into Sinatra::Security::User. The
    # API loosely applies to Ohm, although it will work with ActiveRecord.
    #
    # @example
    #
    #   class User < Ohm::Model
    #     include Sinatra::Security::User
    #   end
    #
    #   User.respond_to?(:find_by_login)
    #   # => true
    #
    #   User.respond_to?(:authenticate)
    #   # => true
    #
    # If you wish to override any of these, it's as simple as defining your
    # own method in your User class.
    module Identification
      # Finds the User matching the given login / password combination.
      # @see Sinatra::Security::Helpers#authenticate
      #
      # @param [#to_s] login the value of `:email` in your datastore.
      # @param [String] password the raw password for the user in `:email`.
      # @return [User] the user matching the credentials if found.
      # @return [nil]  if no matching user found.
      def authenticate(login, password)
        if user = find_by_login(login)
          if Sinatra::Security::Password::Hashing.check(password, user.crypted_password)
            user
          end
        end
      end

      # Used internally by User::authenticate to find the user given the 
      # `:email` value.
      #
      # @param [#to_s] login the value of `:email` in your datastore. You may
      #                also override the key used. 
      # @return [User] an instance of User if found.
      # @return [nil]  if no user found with the given login value.
      #
      # @see Sinatra::Security::LoginField::attr_name
      def find_by_login(login)
        find(__LOGIN_FIELD__ => login).first
      end

    protected
      def __LOGIN_FIELD__
        Sinatra::Security::LoginField.attr_name 
      end
    end
  end
end
