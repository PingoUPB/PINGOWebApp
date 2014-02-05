if !(ENV["USE_JUGGERNAUT"] == "false") && !(ENV["RAILS_GROUPS"] == "assets") &&  !$rails_rake_task
  if Rails.env.production? || Rails.env.staging?
    PINGO_REDIS = Redis.new(url: ENV["REDISTOGO_URL"], driver: :synchrony)
  else
    PINGO_REDIS = Redis.new(url: ENV["REDISTOGO_URL"])
  end
end