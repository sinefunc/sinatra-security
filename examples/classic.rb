require 'sinatra'
require 'sinatra/security'

class ::User
  attr :id
  
  def self.attribute(att)
    @attributes ||= []
    @attributes << att
    attr_accessor att
  end
  include Sinatra::Security::User

  # we override this for the sake of example
  def self.find_by_login(login)
    User.new(42) if login ==  'quentin'
  end
  
  def self.[](id)
    User.new(id)
  end

  def initialize(id = nil)
    @id = id
    @crypted_password = Sinatra::Security::Password::Hashing.update('test')
  end
end

use Rack::Session::Cookie

get "/" do
  haml :home
end

get "/public" do
  "Hello public world"
end

get "/private" do
  require_login

  "Hello private world <a href='/logout'>Logout</a>"
end

get "/login" do
  @user = User.new

  haml :login
end

get "/logout" do
  logout!

  redirect '/'
end
