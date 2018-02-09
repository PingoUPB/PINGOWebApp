source 'http://rubygems.org'
gem 'rails', '~> 5.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'coffee-rails', "~> 4.2.2"
gem 'uglifier', "~> 4.1.6"
gem 'less-rails-bootstrap'
gem "therubyracer", "~> 0.12.3"

gem 'jquery-rails'
gem "googlecharts"
gem 'fancybox-rails'
gem "rspec-rails", ">= 2.6.1", :group => [:development, :test]
gem 'did_you_mean', "~> 1.1.0", group: [:development, :test]
gem 'eventmachine' #, :git => 'git://github.com/eventmachine/eventmachine.git'

group :test do
	gem "database_cleaner", ">= 0.6.7"
	gem "mongoid-rspec", ">= 1.4.4"
	gem "factory_bot_rails"
	gem "cucumber-rails", ">= 1.0.2", :require => false
	gem "capybara", ">= 1.0.1"
	gem "launchy", ">= 2.0.5"
	gem 'cucumber-websteps'
	gem 'capybara-screenshot'
	gem "headless"
	gem "poltergeist" # DEPS: mac: brew install phantomjs / linux: apt-get install phantomjs
	gem 'simplecov', :require => false
end

gem 'mongoid', '~> 6.3.0'
gem 'mongoid-tag-collectible'
gem 'mongoid_token', '~> 4.0.0', git: 'git://github.com/PingoUPB/mongoid_token.git', branch: "rails51-mongoid6"

gem "devise", "~> 4.4.0"

#gem 'mongoid_taggable'

gem "jqcloud-rails"

gem 'formtastic-bootstrap'
gem "cocoon"
gem "seer", ">= 0.10.0"
gem "uuid", ">= 2.3.4"

gem "high_voltage"

gem 'ya2yaml', :groups => [:staging, :development]
#gem 'translate-rails3', :require => 'translate', :groups => [:staging, :development]

gem 'dalli'
gem 'kgio' # speed up dalli

gem 'rack-contrib'

gem 'em-http-request' #, :git => 'git://github.com/igrigorik/em-http-request'
#gem 'mongo', "1.6.2"
#gem 'em-mongo'
gem 'em-synchrony' #, :git => 'git://github.com/igrigorik/em-synchrony.git'

gem 'rack-fiber_pool', :require => 'rack/fiber_pool'

gem "thin"
gem "amnesia", :groups => [:production, :staging], :git => 'git://github.com/PingoUPB/amnesia.git'
gem "foreman", :groups => [:production, :staging]
gem "lograge", :groups => [:production, :staging]

#gem "heroku", :groups => [:heroku]

gem "grit"

#gem 'simple_worker', :group => [:heroku]
gem 'resque'
gem 'capistrano'
gem 'capistrano-newrelic'
# gem 'rvm-capistrano', :group => [:nonheroku]

gem "juggernaut"
gem "oj" # faster JSON parsing

#gem "mongrel", :group => :development

gem 'redis'
gem 'em-redis', '>= 0.3.0'
gem 'em-hiredis'

group :production do
	gem "newrelic_rpm", '>= 3.9.4.245'
end

group :development do
  gem "binding_of_caller", ">= 0.7.1"
  gem "better_errors", "~> 2.4.0"
  gem 'web-console'
  gem 'spring'
  gem "rack-mini-profiler", require: false
end

# gem 'maktoub'

gem 'obscenity', git: "git://github.com/PingoUPB/obscenity.git"

# gem 'better_logging'

gem 'pry-rails', :group => :development

gem 'ruby-standard-deviation'
gem 'histogram', require: 'histogram/array'

gem 'gift-parser', :git => 'git://github.com/PingoUPB/gift-parser.git', :require => 'gift'
