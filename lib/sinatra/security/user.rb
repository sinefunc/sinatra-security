module Sinatra
  module Security
    module User
      def self.included(user)
        user.send :include, Validations
        user.send :include, Password

        user.extend Identification 
      end
    end
  end
end
