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
  attr_accessor :email, :password

  def initialize(id = nil)
    @id = id
  end

  def errors
    @errors ||= []
  end

protected
  def assert(value, error)
    value or errors.push(error) && false
  end

  def assert_present(att, error = [att, :not_present])
    assert(!send(att).to_s.empty?, error)
  end

  def assert_format(att, format, error = [att, :format])
    if assert_present(att, error)
      assert(send(att).to_s.match(format), error)
    end
  end

end

