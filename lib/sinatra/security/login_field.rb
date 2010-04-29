module Sinatra
  module Security
    module LoginField
      def self.attr_name(attr_name = nil)
        @attr_name = attr_name if attr_name
        @attr_name
      end
      attr_name(:email)
      
      def self.included(user)
        user.attribute LoginField.attr_name
        user.index     LoginField.attr_name
      end
    end
  end
end