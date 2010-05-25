Sinatra Security
================

This gem just provides you with the standard authentication mechanisms you would expect from your typical app.

Read the full documentation at [http://labs.sinefunc.com/sinatra-security/doc](http://labs.sinefunc.com/sinatra-security/doc).

Basic usage
-----------
 
    # taken from examples/classic.rb

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

Some advanced stuff you might want to do
----------------------------------------
    
    require 'sinatra'
    require 'sinatra/security'
    require 'ohm'
    
    # we set a different attribute name here. 
    # the default used is :email, but we can choose whatever we want.
    Sinatra::Security::LoginField.attr_name :login

    class User < Ohm::Model
      include Sinatra::Security::User
    end

    user = User.create(:login => "quentin", :password => "test")
    user == User.authenticate("quentin", "test")
    # => true
  
    # in our sinatra context...
    # now let's secure a chunk of our pages
    require_login '/admin/users'

    get '/admin/users/:id' do |id|
      # do something here
    end

    get '/admin/posts' do
      # posts list here
    end

    # we can also do basic atomic authorization checks for our objects

    get '/admin/posts/:id/edit' do |id|
      post = Post[id]
      ensure_current_user post.author # does a `halt 404` if this fails

      # now we proceed as normal, if the author is indeed the curerent user
    end
    
    # a quick demo of how you might want to logout
    get '/logout' do
      logout!
      redirect '/'
    end


Note on Patches/Pull Requests
-----------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------
Copyright (c) 2010 Cyril David. See LICENSE for details.
