Sinatra Security
================

This gem just provides you with the standard authentication mechanisms you would expect from your typical app.

How to use
==========
 
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
