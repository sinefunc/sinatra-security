require "helper"

class DifferentUserClassTest < Test::Unit::TestCase
  class BasicApp < Sinatra::Base
    class Operator < Struct.new(:id)
      def self.authenticate(u, p)
        return new(1001) if u == 'Foo' && p == 'Bar'
      end
    end

    use Rack::Session::Cookie

    register Sinatra::Security
    
    set :login_user_class, lambda { Operator }

    get '/secured' do
      require_login

      "Secured!"
    end
  end

  describe "an app with a different user class" do
    def app
      BasicApp.new
    end

    test "blocks non-authenticated users properly" do
      get '/secured'
      
      assert_equal 302, last_response.status
      assert_equal '/login', last_response.headers['Location']
    end

    test "authenticates properly" do
      post '/login', :username => "Foo", :password => "Bar"
      
      assert_equal 302, last_response.status
      assert_equal '/', last_response.headers['Location']

    end
  end
end
