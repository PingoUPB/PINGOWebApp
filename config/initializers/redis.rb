if !(ENV["USE_JUGGERNAUT"] == "false") && !(ENV["RAILS_GROUPS"] == "assets") &&  !$rails_rake_task
    PINGO_REDIS = Redis.new(url: ENV["REDISTOGO_URL"])
end