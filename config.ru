# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if Rails.env.production? || Rails.env.staging?
  rescue_exception = Proc.new { |env, exception| [503, {}, "We're really sorry, something did not work as expected. Please go back and try again later. Check http://STATUSWEBSITE for a current system status; contact MAILADRESS if error persists (and tell them 'it's the fibers'). Thanks!"] }
  use Rack::FiberPool, :rescue_exception => rescue_exception, :size => 1000
  puts "using FiberPool"
end

run Eclickr::Application
