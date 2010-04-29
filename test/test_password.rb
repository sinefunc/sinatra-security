require "helper"

class FakeOhm
  def self.attribute(att)
  end

  def write
    :real_write_response
  end

protected
  def write_local(att, value)
  end
end

class UserWithPassword < FakeOhm
  include Sinatra::Security::Password
end

class TestPassword < Test::Unit::TestCase
  include Sinatra::Security

  describe "#update" do
    should "return a 192 character string" do
      assert_equal 192, Password::Hashing.update('123456').length
    end
  end

  describe "#check" do
    should "be able to match the original password given" do
      @password = 'password100'

      assert Password::Hashing.check(@password, Password::Hashing.update(@password))
    end
  end

  describe "#write when Password is included" do
    setup do
      @user = UserWithPassword.new
    end

    should "return the original write response" do
      assert_equal :real_write_response, @user.send(:write)
    end

    should "write the crypted password given and match the original via #check" do
      @user.password = 'password'
      @crypted_password = nil
      @user.expects(:write_local).with() { |field, v| 
        field == :crypted_password && !(@crypted_password = v).nil?
      }

      @user.send(:write)

      assert Password::Hashing.check('password', @crypted_password)
    end

    should "not write a crypted password when the password is empty" do
      @user.password = ''
      @crypted_password = nil
      @user.stubs(:write_local).raises(RuntimeError)
      
      assert_nothing_raised RuntimeError do
        @user.send(:write)
      end
      
      assert_nil @crypted_password
    end
  end
end
