source 'http://rubygems.org'
gem 'rails', '= 3.2.22'
gem "strong_parameters", "~> 0.1.5" # Rails 4 style attr_accessible / https://github.com/rails/strong_parameters

group :assets do
  gem 'coffee-rails', "~> 3.2.2"
  gem 'uglifier', "~> 1.3.0"
  gem 'less-rails-bootstrap'
  gem "therubyracer", "~> 0.12.1"
end

gem 'jquery-rails'
gem "googlecharts"
gem 'fancybox-rails'
gem "rspec-rails", ">= 2.6.1", :group => [:development, :test]
gem 'did_you_mean', group: [:development, :test]
gem 'eventmachine' #, :git => 'git://github.com/eventmachine/eventmachine.git'

group :test do
	gem "database_cleaner", ">= 0.6.7"
	gem "mongoid-rspec", ">= 1.4.4"
	gem "factory_girl_rails", "~> 4.0"
	gem "cucumber-rails", ">= 1.0.2", :require => false
	gem "capybara", ">= 1.0.1"
	gem "launchy", ">= 2.0.5"
	gem 'cucumber-websteps'
	gem 'capybara-screenshot'
	gem "headless"
	gem "poltergeist" # DEPS: mac: brew install phantomjs / linux: apt-get install phantomjs
	gem 'simplecov', :require => false
end

gem "bson_ext", ">= 1.6.4"
gem "mongoid", "2.4.12"
gem "devise", "~> 2.1.4"

gem 'mongoid_taggable'
gem "jqcloud-rails"

gem 'formtastic-bootstrap'
gem 'mongoid_token', '1.0.0'
gem "cocoon"
gem "seer", ">= 0.10.0"
gem "uuid", ">= 2.3.4"

gem "high_voltage"

gem 'ya2yaml', :groups => [:staging, :development]
gem 'translate-rails3', :require => 'translate', :groups => [:staging, :development]

gem 'dalli'
gem 'kgio' # speed up dalli

gem 'rack-contrib'

gem 'em-http-request' #, :git => 'git://github.com/igrigorik/em-http-request'
gem 'mongo', "1.6.2"
gem 'em-mongo'
gem 'em-synchrony' #, :git => 'git://github.com/igrigorik/em-synchrony.git'

gem 'rack-fiber_pool', :require => 'rack/fiber_pool'

gem "thin"
gem "amnesia", :groups => [:production, :staging], :git => 'git://github.com/PingoUPB/amnesia.git'
gem "foreman", :groups => [:production, :staging, :nonheroku]
gem "lograge", :groups => [:production, :staging]

#gem "heroku", :groups => [:heroku]

gem "grit"

#gem 'simple_worker', :group => [:heroku]
gem 'resque', :group => [:nonheroku]
gem 'capistrano', :group => [:nonheroku]
gem 'rvm-capistrano', :group => [:nonheroku]

gem "juggernaut"

#gem "mongrel", :group => :development

gem 'em-redis', '>= 0.3.0'
gem 'em-hiredis'

group :production do
	gem 'rpm_contrib'
	gem "newrelic_rpm", '>= 3.9.4.245'
end

group :development do
  gem "binding_of_caller", ">= 0.7.1", platforms: [:mri_19, :rbx]
  gem "better_errors", "~> 1.1.0"
  gem "rack-mini-profiler", require: false
end

gem 'maktoub'

gem 'obscenity', git: "git://github.com/PingoUPB/obscenity.git"

gem 'better_logging'

gem 'pry-rails', :group => :development

gem 'ruby-standard-deviation'
gem 'histogram', require: 'histogram/array'

gem 'gift-parser', :git => 'git://github.com/PingoUPB/gift-parser.git', :require => 'gift'
