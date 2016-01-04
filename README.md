Welcome to PINGO (former code name: eClickr)
=====

Licensed under the Eclipse Public License -v 1.0 (see `LICENSE.txt`).

originally made by Michael Whittaker / <http://www.michael-whittaker.de>

see <http://pingo.upb.de/humans.txt> for a contributor list.

This project was made for a university project with the Chair for Information management and E-Finance of the University of Paderborn. / <http://www.upb.de/winfo2>

Requirements
------

* Ruby 1.9.3, RubyGems, Bundler (not tested with Windows or JRuby; newer Rubies work, but are not tested for high performance.)
* Gems: Bundler, for dependencies see `Gemfile`
* MongoDB (tested with 2.x)
* Thin Webserver (recommended for high performance, not neccessary)

* Memcache or Redis for Caching (optional)
* Juggernaut (Github: maccman/juggernaut) and Redis (www.redis.io) optional, required for push support. Push support is enabled by default in production mode.)
* for Heroku: SimpleWorker account (optional, you can use Resque instead. Use of SimpleWorker is disabled by default.)

Install / Run for dev
---------

1. run `bundle install`

2. start MongoDB (see <http://www.mongodb.org/display/DOCS/Quickstart>) and create an user eclickr:eclickr for database eclickr: `[on command-client:] mongo [ENTER] use eclickr [ENTER] db.addUser("eclickr", "eclickr") [ENTER] exit`

3. run `bundle exec rake secret` and enter the generated key in `config/initializers/secret_token.rb`; or setup an environment variable named `PINGO_RAILS_SECRET_TOKEN` that contains the value from the `rake secret` command. Do _not_ publish your secret token in the public!

4. `bundle exec rails server` or `bundle exec foreman start` (see Procfile for foreman setup)

5. surf to <http://localhost:3000/> (or http://localhost:5000/ if you used forman). View from smartphone to see mobile view for participants.

6. sign up as a user and run the following to become an admin: `bundle exec rails runner 'User.first.update_attribute(:admin, true)'` or run `bundle exec rake db:seed` to create a default admin user named user@example.com. (Warning: running db:seed empties your database!)

7. start Redis and Juggernaut and set URL in `environments/development.rb` (and restart server) for push support.

Styling
---------

See the `stylesheepts/custom_bootstrap/variables.less` for more info. Some information can also be found in the Github Wiki.

Production
---------

This varies from setup to setup. However, we have good experience using NGINX as a reverse proxy. For high performance, make sure you run the Rails app with the Thin webserver and in production mode, i. e. running the server command with the prefix `RAILS_ENV=production` (you can also set ENV vars in your OS). Use TLS/SSL to protect your user data and backup your database regurarily.
Setup the `config/environments/production.rb` file and check the `config/initializers`-files.
Precompile your assets and serve them with a webserver.
Also, add a link to an imprint in the `app/views/layouts/application.html.erb`.

I18n
------

eClickr is localized with default Rails I18n. It uses a rack middleware to set the locale according to the viewer's browser. Files are in `config/locales/`.

Configuration
--------

You can configure most settings in the envireonments-files (i. e. `config/environments/{development|production}.rb`) and at `config/initializers/*`. The settings are split up because the environment on a developer's machine probably never is the same as the one for production (Caching, Juggernaut, Database, ...).
The settings are named straight-forward and some are also commented.


Tests
-------

Run `bundle exec cucumber` to run our integration tests (files at  `features/*`).

Run `bundle exec rspec` to run our specs (files at  `spec/*`).

More Info
-------

* Rails Guides at <http://guides.rubyonrails.org/v3.2.22/>
* <http://www.trypingo.com> for more information about features and the team
* <http://www.upb.de/pingo> (our more detailed project website) and <http://blog.pingo-projekt.de> (our blog)
* if you need support, please open an issue at GitHub: https://github.com/PingoUPB/PINGOWebApp/issues/new
* (or contact us at pingo-support…ät…uni-paderborn.de if you cannot post a publicly visible ticket)
* If you would like to contribute, please fork and create a pull request on Github.
