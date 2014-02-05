# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Eclickr::Application.initialize!

# https://github.com/logentries/le_ruby
if ENV["LOGENTRIES_TOKEN"] && ENV["LOGENTRIES_TOKEN"] != "" && defined?(Le)
    Rails.logger = Le.new(ENV["LOGENTRIES_TOKEN"])
end