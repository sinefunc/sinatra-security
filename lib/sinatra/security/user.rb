module Sinatra
  module Security
    # Mixes in to any included class all of the following:
    # 
    # * Sinatra::Security::LoginField
    # * Sinatra::Security::Password
    # * Sinatra::Security::Validations
    #
    # It also extends the class with Sinatra::Security::Identification.
    #
    # @example
    #   
    #   class User < Ohm::Model
    #     include Sinatra::Security::User
    #   end
    #
    #   user = User.new
    #   user.valid?
    #   user.errors == [[:email, :not_present], [:password, :not_present]]
    #   # => true
    #
    #   user = User.create(:email => "test@example.com", :password => "pass",
    #                      :password_confirmation => "pass")
    #
    #   User.authenticate("test@example.com", "pass") == user
    #   # => true
    #
    module User
      def self.included(user)
        user.send :include, LoginField
        user.send :include, Password
        user.send :include, Validations

        user.extend Identification 
      end
    end
  end
end
