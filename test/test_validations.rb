require "helper"

class UserWithEmailValidation < TestFixtures::User
  include Sinatra::Security::Validations
 
  def initialize
    super

    @password = 'password'
    @password_confirmation = 'password'
  end

  def validate
    assert_login_using_email :email
  end
  
  def errors
    @errors ||= []
  end
end

class UserWithPasswordValidation < TestFixtures::User
  include Sinatra::Security::Validations

  def initialize
    super
    
    @email = 'real@email.com'
  end

  def validate
    assert_password :password
  end
  
  def errors
    @errors ||= []
  end
end

class UserDefaultValidation < TestFixtures::User
  include Sinatra::Security::Validations

  def errors
    @errors ||= []
  end
end

class TestValidations < Test::Unit::TestCase
  context "without an email" do
    should "require the email to be present" do
      user = UserWithEmailValidation.new
      user.validate

      assert_equal [[:email, :not_present]], user.errors
    end
  end

  context "with an email _not_an_email_" do
    should "have an error in the format" do
      user = UserWithEmailValidation.new
      user.email = '_not_an_email_'
      user.validate

      assert_equal [[:email, :not_email]], user.errors
    end
  end

  context "given a real deal email" do
    should "check if it's actually unique" do
      user = UserWithEmailValidation.new
      user.email = 'real@email.com'

      user.expects(:assert_unique).with(:email)
      user.validate
    end
  end

  context "without a password" do
    context "when it's a new User" do
      should "have a password error" do
        user = UserWithPasswordValidation.new
        user.stubs(:new?).returns(true)
        user.validate

        assert_equal [[:password, :not_present]], user.errors
      end
    end

    context "when it's an existing user" do
      should "not require a password" do
        user = UserWithPasswordValidation.new
        user.stubs(:new?).returns(false)
        user.validate

        assert_equal [], user.errors
      end
    end
  end

  context "a new User with a password and no confirmation" do
    setup do
      @user = UserWithPasswordValidation.new
      @user.password = 'password'
      @user.stubs(:new?).returns(true)
    end
    
    should "have a password confirmation error" do
      @user.validate
      assert_equal [[:password, :not_confirmed]], @user.errors
    end

    context "when the password confirmation is filled up but mismatched" do
      should "still have a password confirmation error" do
        @user.password_confirmation = 'password1'
        @user.validate
        assert_equal [[:password, :not_confirmed]], @user.errors
      end
    end
  end

  context "an existing User with a password and no confirmation" do
    setup do
      @user = UserWithPasswordValidation.new
      @user.password = 'password'
      @user.stubs(:new?).returns(false)
    end
    
    
    should "have a password confirmation error" do
      @user.validate
      assert_equal [[:password, :not_confirmed]], @user.errors
    end

    context "when mismatched confirmation is filled up" do
      should "still have a confirmation error" do
        @user.password_confirmation = 'password1'
        @user.validate
        assert_equal [[:password, :not_confirmed]], @user.errors
      end
    end
  end

  context "given correct passwords" do
    setup do
      @user = UserWithPasswordValidation.new
      @user.password = 'password'
      @user.password_confirmation = 'password'
    end
  
    context "when new user" do
      should "have no errors" do
        @user.stubs(:new?).returns(true)
        @user.validate
        assert @user.errors.empty?
      end
    end

    context "when existing user" do
      should "have no errors" do
        @user.stubs(:new?).returns(false)
        @user.validate
        assert @user.errors.empty?
      end
    end
  end

  context "the default validations" do
    setup do
      @user = UserDefaultValidation.new
      @user.stubs(:new?).returns(true)
    end

    should "assert presence of email" do
      @user.validate

      assert @user.errors.include?([:email, :not_present])
    end

    should "assert the email is an email" do
      @user.email = '_foobar_'
      @user.validate

      assert @user.errors.include?([:email, :not_email])
    end

    should "assert the email is unique" do
      @user.email = 'foo@bar.com'
      @user.expects(:assert_unique).with(:email).returns(false)
      @user.validate
    end

    should "assert the password is there" do
      @user.password = ''
      @user.validate
      assert @user.errors.include?([:password, :not_present])
    end

    should "assert the password is confirmed" do
      @user.password = 'aoeu'
      @user.validate
      assert @user.errors.include?([:password, :not_confirmed])
    end

    context "when the user is existing" do
      should "not require a password" do
        @user.stubs(:new?).returns(false)
        @user.validate

        assert ! @user.errors.include?([:password, :not_presen])
      end
    end
  end
end
