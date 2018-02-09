Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  
  config.eager_load = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :dalli_store, "example.com", { :async => true }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  config.threadsafe! unless $rails_rake_task
  #config.eager_loading = true # RAILS4 # rails 4

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = false

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  config.action_mailer.default_url_options = { :host => 'pingo-beta.example.com' }
  
  # https://github.com/romanbsd/translate
  #config.from_locales = [:en]
  #config.to_locales = [:es]
  
  # lograge config / https://github.com/roidrage/lograge
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    {ip: event.payload[:ip]}
  end
end

  # Juggernaut Server
  ENV["USE_JUGGERNAUT"] = "false" # make sure to somehow namespace if using same server for production
  ENV["JUGGERNAUT_HOST"] = "ws.example.com"
  ENV["JUGGERNAUT_PORT"] = "8080"
  ENV["FAYE_ENABLED"] == "true" # should events be sent to faye
  ENV["JUGGERNAUT_ENABLED"] == "true" # should events be sent to juggernaut
  
  # Git version display in logo (set automatically at heroku)
  #repo = Grit::Repo.new(Rails.root + '.git')
  #last_commit = repo.commits.first
  #ENV['COMMIT_HASH'] = last_commit.id+"/"+last_commit.authored_date.to_s
  ENV['COMMIT_HASH'] = "unknown"
  ENV["PUSH_URL"] = ENV["JUGGERNAUT_URL"] = "http://#{ENV["JUGGERNAUT_HOST"]}:8888/faye"

  # Git version display in logo
  repo = Grit::Repo.new(Rails.root + '.git')
  last_commit = repo.commits.first
  ENV['COMMIT_HASH'] = last_commit.id+"/"+last_commit.authored_date.to_s
  
  ENV["REDISTOGO_URL"] = "redis://127.0.0.1:6379"
  ENV["MONGOHQ_URL"] = "mongodb://user:pass@127.0.0.1:27017/eclickr_staging"
  ENV["MEMCACHE_PASSWORD"] = ""
  ENV["MEMCACHE_SERVERS"] = "127.0.0.1"
  ENV["MEMCACHE_USERNAME"] = ""
  
  ENV["NEW_RELIC_APP_NAME"] = ""
  ENV["NEW_RELIC_LICENSE_KEY"] = ""

# Domain without slash
ENV["URL_PREFIX"] = "http://example.com" # make sure you also set the URL for action mailer at the end of the config block above

# organization subnet
ENV["ORG_SUBNET"] = "131.234.0.0/16"

ENV["ANALYTICS"] = "false" # tracks some statistics about usage (not to be confused with google analytics)

# no debug messages in production mode
def pprint(arg)
  true
end
