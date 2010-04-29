module Sinatra
  module Security
    module Identification
      def find_by_login(login)
        find(:email => login).first
      end

      def authenticate(login, pass)
        if user = find_by_login(login)
          if Sinatra::Security::Password::Hashing.check(pass, user.crypted_password)
            user
          end
        end
      end
    end
  end
end
