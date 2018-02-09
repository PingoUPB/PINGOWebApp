require 'rack/contrib' # https://github.com/rack/rack-contrib

module Eclickr
  class Application < Rails::Application
    # Detects the client locale using the Accept-Language request header and sets a rack.locale variable in the environment.
    config.middleware.use Rack::Locale
  end
end