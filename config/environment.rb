# Load the Rails application.
require_relative 'application'

# Initialize the rails application
Rails.application.initialize!
#Eclickr::Application.initialize!

# https://github.com/logentries/le_ruby
if ENV["LOGENTRIES_TOKEN"] && ENV["LOGENTRIES_TOKEN"] != "" && defined?(Le)
    Rails.logger = Le.new(ENV["LOGENTRIES_TOKEN"])
end