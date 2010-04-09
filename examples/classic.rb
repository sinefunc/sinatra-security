require 'sinatra'
require 'sinatra/security'

class User
  attr :id

  def self.authenticate(user, pass)
    User.new(42) if [ user, pass ] == [ 'quentin', 'test' ]  
  end
  
  def self.[](id)
    User.new(id)
  end

  def initialize(id = nil)
    @id = id
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
