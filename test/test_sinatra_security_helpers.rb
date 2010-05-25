require 'helper'

class ExecutionContext < Struct.new(:session, :request)
  def redirect(path)
  end
end

include TestFixtures

class TestSinatraSecurityHelpers < Test::Unit::TestCase
  setup do
    @context = ExecutionContext.new({})
    @context.extend Sinatra::Security::Helpers
  end

  should "respond to current_user" do
    assert_respond_to @context, :current_user
  end

  should "respond to logged_in?" do
    assert_respond_to @context, :logged_in?
  end

  should "respond_to ensure_current_user" do
    assert_respond_to @context, :ensure_current_user
  end

  describe "when session[:user] is set to 1" do
    setup do
      @settings = stub("Settings", :login_user_class => :User)

      @context.stubs(:settings).returns(@settings)
      @context.session[:user] = 1
    end

    should "try and find the the User by id 1" do
      User.expects(:[]).with(1).returns(:user)
      
      @context.current_user
    end

    should "return the found user as the result" do
      User.stubs(:[]).returns(:user)

      assert_equal :user, @context.current_user
    end
  end

  describe "when current_user is not nil" do
    should "be logged_in?" do
      @context.stubs(:current_user).returns(:user)

      assert @context.logged_in?
    end
  end

  describe "when current_user is nil" do
    should "not be logged_in?" do
      @context.stubs(:current_user).returns(nil)

      assert ! @context.logged_in?
    end
  end
  
  describe "#ensure_current_user" do
    context "when the current_user is not the same as the asserted user" do
      should "halt 404" do
        @context.expects(:halt).with(404)

        @context.stubs(:current_user).returns(:user1)
        @context.ensure_current_user(:user2)
      end
    end
    
    context "when the current_user is the same as the asserted user" do
      should "not halt 404" do
        @context.stubs(:halt).raises(RuntimeError)
        @context.stubs(:current_user).returns(:user1)

        assert_nothing_raised do
          @context.ensure_current_user(:user1)
        end
      end
    end
  end
  
  describe "#require_login" do
    context "when logged_in?" do
      should "not redirect" do
        @settings = stub("Settings", :ignored_by_return_to => /foobared$/,
                                     :login_url => '/new-login-url')
        @context.stubs(:settings).returns(@settings)


        @context.expects(:redirect).never
        @context.expects(:logged_in?).returns(true)

        @context.require_login 
      end
    end

    context "when not logged_in?" do
      setup do
        @context.stubs(:logged_in?).returns(false)
        @settings = stub("Settings", :ignored_by_return_to => /foobared$/,
                                     :login_url => '/new-login-url')

        @context.stubs(:settings).returns(@settings)

        @context.request = stub("Request", :fullpath => "/some/fullpath/here")
      end

      should "set return_to of request.fullpath" do
        @context.require_login

        assert_equal "/some/fullpath/here", @context.session[:return_to]
      end

      should "redirect to /login" do
        @context.expects(:redirect).with('/new-login-url')

        @context.require_login
      end

      should "return false" do
        assert ! @context.require_login
      end

      context "when the request matches ignored" do
        should "not store the fullpath in return_to" do
          @context.request = stub("Request", :fullpath => "/some/fullpath/foobared")
          @context.require_login

          assert_nil @context.session[:return_to]
        end
      end
    end
  end

  describe "#logout" do
    should "set the remove the session[:user]" do
      @context.session[:user] = 1
      @context.logout!

      assert ! @context.session[:user]
    end
  end
end
