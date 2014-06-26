Welcome to PINGO (former code name: eClickr)
=====

Licensed under the Eclipse Public License -v 1.0 (see `LICENSE.txt`).

originally made by Michael Whittaker / <http://www.michael-whittaker.de>

see <http://pingo.upb.de/humans.txt> for a contributor list.

This project was made for a university project with the Chair for Information management and E-Finance of the University of Paderborn. / <http://www.upb.de/winfo2>

Requirements
------

* Ruby 1.9.3, RubyGems, Bundler (not tested with Windows or JRuby)
* Gems: Bundler, for dependencies see `Gemfile`
* MongoDB
* Thin Webserver (recommended for high performance, not neccessary)

* for Heroku: SimpleWorker account (optional, you can use Resque insted. Use of SimpleWorker is disabled by default.)
* Juggernaut and Redis (optional, required for push support. Push support is enabled by default in production mode.)

Install / Run
---------

1. `bundle install`

2. start MongoDB (see <http://www.mongodb.org/display/DOCS/Quickstart>) and create an user eclickr:eclickr for database eclickr: `[on command-client:] mongo [ENTER] use eclickr [ENTER] db.addUser("eclickr", "eclickr") [ENTER] exit`

3. `bundle exec rake db:seed` (this will empty your MongoDB, be careful)

4. `bundle exec rails server` or `bundle exec foreman start` (see Procfile for foreman setup)

5. surf to <http://localhost:3000/> (or http://localhost:5000/ if you used formeman) and login with user@test.com and Passwort "please". View from phone to see mobile view for participants.

6. start Redis and Juggernaut and set URL in environments/development.rb (and restart server) for push support.

I18n
------

eClickr is localized with default Rails I18n. It uses a rack middleware to set the locale according to the viewer's browser. Files are in `config/locaes/`.

Configuration
--------

You can configure most settings in the envireonments-files (i. e. `config/environments/{development|production}.rb`) and at `config/initializers/*`. The settings are split up because the environment on a developer's machine probably never is the same as the one for production (Caching, Juggernaut, Database, ...). 
The settings are named straight-forward and some are also commented.


Tests
-------

Run <tt>bundle exec cucumber</tt> to run our integration tests (files at  `features/*`).

More Infos
-------

* Rails Guides at <http://guides.rubyonrails.org/v3.2.13/>
* <http://www.trypingo.com> for more information about features and the team
* <http://www.upb.de/pingo> (our more detailed project website) and <http://blog.pingo-projekt.de> (our blog)
* if you need support, please open an issue at GitHub: https://github.com/PingoUPB/PINGOWebApp/issues/new
* (or contact us at pingo-support…ät…uni-paderborn.de if you cannot post a publicly visible ticket)
* If you would like to contribute, please fork and create a pull request on Github.