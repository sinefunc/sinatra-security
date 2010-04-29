module Sinatra
  module Security
    module Validations
      EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

    protected
      def assert_login_using_email(att, error = [att, :not_email])
        if assert_present att
          if assert_format att, EMAIL_FORMAT, error
            assert_unique att
          end
        end
      end

      def assert_password(att, error = [att, :not_present])
        confirmation_att = :"#{ att }_confirmation"

        if new? && assert_present(att) || !send(att).to_s.empty?
          assert send(att) == send(confirmation_att), [att, :not_confirmed]
        end
      end
    end
  end
end
