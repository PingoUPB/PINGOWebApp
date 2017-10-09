if defined?(Juggernaut)
Juggernaut.options = {driver: :synchrony} if (Rails.env.production? || Rails.env.staging? ) && !$rails_rake_task
  Juggernaut.url = ENV["REDISTOGO_URL"]
end