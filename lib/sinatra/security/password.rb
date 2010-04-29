require 'digest/sha2'

module Sinatra
  module Security
    module Password
      def self.included(base)
        base.send :attribute, :crypted_password
        base.send :attr_accessor, :password, :password_confirmation
      end

    protected
      def write
        if !password.to_s.empty?
          write_local :crypted_password, Sinatra::Security::Password::Hashing.update(password)
        end

        super
      end

      module Hashing
        extend self

        # Generates a new salt and rehashes the password
        def update(password)
          salt = self.salt
          hash = self.hash(password,salt)
          self.store(hash, salt)
        end

        # Checks the password against the stored password
        def check(password, stored)
          hash = self.get_hash(stored)
          salt = self.get_salt(stored)

          self.hash(password, salt) == hash
        end

      protected
        # Generates a psuedo-random 64 character string
        def salt
          salt = ""
          64.times { 
            salt << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
          salt
        end

        # Generates a 128 character hash
        def hash(password, salt)
          Digest::SHA512.hexdigest("#{ password }:#{ salt }")
        end

        # Mixes the hash and salt together for storage
        def store(hash, salt)
          hash + salt
        end

        # Gets the hash from a stored password
        def get_hash(stored)
          stored[0..127]
        end

        # Gets the salt from a stored password
        def get_salt(stored)
          stored[128..192]
        end
      end
    end
  end
end
