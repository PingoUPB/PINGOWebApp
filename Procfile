web: bundle exec thin start -S /tmp/thin.$PORT.sock --max-persistent-conns 300
worker: bundle exec rake resque:work