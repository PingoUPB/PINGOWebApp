#class Swagger::Docs::Config
  #def self.base_api_controller; ApiController end
#end

Swagger::Docs::Config.register_apis({
  "1.1" => {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    :api_file_path => "public/api-docs/v1/",
    # the URL base path to your API
    :base_path => "https://pingo.upb.de/",
    # if you want to delete all .json files at each generation
    :clean_directory => false,
    # add custom attributes to api-docs
    :attributes => {
      :info => {
        "title" => "PINGO API v1",
        "description" => "Some API endpoints for PINGO's most important features as used by our apps. See *trypingo.com* for info about PINGO. *NOTE: Most actions are connected to a registered user and thus require an authentication token. See /api about how to get a token.*",
        "contact" => "pingo-support@upb.de",
        "termsOfService" => "This API is generally available. Please ONLY use the API via https, i. e. SSL/TLS and never store a user's password. Although this API is provided as is with no support or availability guarantee, we are happy to hear your feedback. Parts of the API may change without prior announcement; follow our blog or our Github repository to stay updated.",
        "license" => "Eclipse Public License - v 1.0",
        "licenseUrl" => "https://www.eclipse.org/legal/epl-v10.html"
      }
    }
  }
})

if Rails.env.development?

  class CorsMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      default_headers = {
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, POST, DELETE, PUT, PATCH, OPTIONS',
        'Access-Control-Allow-Headers' => 'Content-Type, api_key, auth_token, Authorization, origin'
      }
      if env["REQUEST_METHOD"] == "OPTIONS"
        puts "CorsMiddleware: Intercepted OPTIONS request: #{env["REQUEST_URI"]}"
        return [200, default_headers, ["<html><body><h1>Intercepted</h1><p>This <b>#{env["REQUEST_METHOD"]}</b> request was intercepted by the CorsMiddleware</p></body></html>"]] 
      end
      status, headers, body = @app.call(env)
      [status, headers.merge(default_headers), body]
    end  
  end

  module Eclickr
    class Application < Rails::Application
      # Middleware for setting CORS headers (for dev testing API with swagger UI)
        config.middleware.insert_before ActionDispatch::Static, CorsMiddleware 
    end
  end

end