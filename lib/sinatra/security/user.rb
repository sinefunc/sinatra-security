module Sinatra
  module Security
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