require 'helper'

class BasicApp < Sinatra::Base
  use Rack::Session::Cookie

  register Sinatra::Security

  get '/public' do
    "Hello Public World"
  end

  get '/private' do
    require_login
    # session[:return_to] = request.fullpath
    # redirect '/login'
  end
end

class TestSinatraSecurity < Test::Unit::TestCase
  def app
    BasicApp.new
  end

  describe "accessing a public url" do
    should "not redirect to login" do
      get '/public'
      assert_equal "Hello Public World", last_response.body      
    end
  end

  describe "accessing a private url" do
    setup do
      get '/private'
    end

    should "redirect to /login" do
      assert_redirected_to '/login'
    end

    should "store in the session the source" do
      assert_equal "/private", session[:return_to]
    end
  end

  describe "accessing a private url with query string params" do
    setup do
      get "/private?query=string&params=true"
    end

    should "also save the query string parameters" do
      assert_equal "/private?query=string&params=true", session[:return_to] 
    end
  end

  describe "accessing a private url with a method other than GET" do
    [ :post, :delete, :put ].each do |method|
      setup do
        send method, "/private"
      end

      should "not save any return_to for #{method}" do
        assert ! session[:return_to]
      end
    end
  end

  describe "being redirected and then logging in" do
    setup do
      get '/private'
  
      @user = User.new(1)
      User.expects(:authenticate).with('quentin', 'test').returns(@user)

      post '/login', username: 'quentin', password: 'test'
    end

    should "redirect to /private" do
      assert_redirected_to '/private'      
    end
  end

  describe "being redirected to login and failing authenticating" do
    setup do
      get '/private'
  
      User.expects(:authenticate).with('quentin', 'test').returns(nil)

      post '/login', username: 'quentin', password: 'test'
    end

    should "redirect render /login" do
      assert_match %r{<h1>Login Page</h1>}, last_response.body
    end

  end
end
