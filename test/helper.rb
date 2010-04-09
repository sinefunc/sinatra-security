require 'rubygems'
require 'test/unit'
require 'contest'
require 'rack/test'
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sinatra/security'

class Test::Unit::TestCase
  include Rack::Test::Methods
  
  protected
    def assert_redirected_to(path)
      assert_equal 302, last_response.status
      assert_equal path, last_response.headers['Location']
    end

    def session
      last_request.env["rack.session"]  
    end
end

# Test Fixtures appear here
class User
  attr :id

  def initialize(id)
    @id = id
  end
end

