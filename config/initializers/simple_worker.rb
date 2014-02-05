# the workers need to connect to the DB in order to return the accurate time
filename = File.join(File.dirname(__FILE__), "..", "mongoid.yml")
DATABASE = YAML.load(ERB.new(File.new(filename).read).result)

if ENV["PLATTFORM"] == "heroku"
  SimpleWorker.configure do |config|
    config.token = ENV['SIMPLE_WORKER_TOKEN']
    config.project_id = ENV['SIMPLE_WORKER_PROJECT_ID']
    config.global_attributes[:mongodb_settings] = DATABASE[Rails.env]
  end
elsif (Rails.env.production? || Rails.env.staging?) && ENV["PLATTFORM"] != "heroku" && ENV["RAILS_GROUPS"] != "assets"
  uri = URI.parse(ENV["REDISTOGO_URL"])
  require "resque"
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end