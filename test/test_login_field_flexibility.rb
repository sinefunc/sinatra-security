require "helper"

class LoginFieldFlexbilityTest < Test::Unit::TestCase
  def setup
    Sinatra::Security::LoginField.attr_name :login
  end

  def teardown
    Sinatra::Security::LoginField.attr_name :email 
  end
  
  class DiffUser
    def self.attribute(att)
    end
    
    def self.index(att)
    end

    include Sinatra::Security::User
  end
  
  test "find_by_login uses :login" do
    @set = stub("Set", :first => :user)
    DiffUser.expects(:find).with(:login => 'foobar').returns(@set)

    assert_equal :user, DiffUser.find_by_login('foobar')
  end

  test "authenticate method uses :login" do
    @user = stub("User", :id => 1001, :crypted_password => '_crypted_')
    @set = stub("Set", :first => @user)
    DiffUser.expects(:find).with(:login => 'foobar').returns(@set)


    DiffUser.authenticate('foobar', 'pass')
  end
end
