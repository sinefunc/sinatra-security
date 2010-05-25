require 'digest/sha2'

module Sinatra
  module Security
    # This module handles everything related to password handling.
    # 
    # @example
    #   
    #   class User < Ohm::Model
    #     include Sinatra::Security::Password
    #   end
    #
    #   User.attributes == [:crypted_password]
    #   # => true
    #
    #   User.new.respond_to?(:password)
    #   # => true
    #
    #   User.new.respond_to?(:password_confirmation)
    #   # => true
    #       
    # @see http://ohm.keyvalue.org for information about Ohm::Model.
    module Password
      def self.included(model)
        model.attribute :crypted_password

        model.send :attr_accessor, :password, :password_confirmation
      end

    protected
      # @private internally called by Ohm after validation when persisting.
      def write
        if !password.to_s.empty?
          write_local :crypted_password, Hashing.encrypt(password)
        end

        super
      end

      module Hashing
        extend self

        # Given any string generates a string which includes both the
        # 128 character (SHA512) hash and the salt.
        #
        # By default the salt is a 64 character pseudo-random string.
        #
        # @example
        #
        #   include Sinatra::Security
        #
        #   crypted = Password::Hashing.encrypt('123')
        #   crypted.length == 192
        #   # => true
        #
        #   crypted = Password::Hashing.encrypt('123', '123456789012')
        #   crypted.length == 140 # i.e. 128 + 12 chars
        #   # => true
        #
        #   crypted = Password::Hashing.encrypt('123')
        #   Password::Hashing.check('123', crypted)
        #   # => true
        #   
        #
        # @param [String] password any string with any length.
        # @param [String] salt (defaults to Hashing#salt) any string.
        # @return [String] a string holding the crypted password and the salt.
        #
        # @see Sinatra::Security::Password::Hashing#check
        def encrypt(password, salt = self.generate_salt)
          serialize(hash(password, salt), salt)
        end

        # Checks the password against the serialized password.
        #
        # @example
        #
        #   include Sinatra::Security
        #   crypted = Password::Hashing.encrypt('123')
        #   Password::Hashing.check('123', crypted)
        #   # => true
        #
        # @param [String] password a string to check against crypted.
        # @param [String] crypted the serialized string containing the 
        #                 hash and salt.
        #
        # @return [true] if the password matches the hash / salt combination.
        # @return [false] if the password does not match the hash / salt.
        def check(password, crypted)
          hash, salt = unserialize(crypted)

          self.hash(password, salt) == hash
        end

      protected
        # Generates a psuedo-random 64 character string
        def generate_salt
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
        def serialize(hash, salt)
          hash + salt
        end
        
        # Returns the original hash and salt generated from serialize.
        def unserialize(serialized)
          return serialized[0..127], serialized[128..-1]
        end
      end
    end
  end
end
