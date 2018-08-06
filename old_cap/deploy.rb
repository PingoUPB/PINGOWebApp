set :rvm_require_role, :app
set :rvm_ruby_string, '2.4.1'
# Load RVM's capistrano plugin.
require "rvm/capistrano"

# require 'new_relic/recipes'
require "bundler/capistrano"


server "co08.coactum.de", :app, :web, primary: true

set :application, "eclickr"
set :rails_env, "production"
set :user, "pingo"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:PingoUPB/PINGOWebApp.git"
set :branch, "rail51"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases
after "deploy:update", "mongoid:index"
after "deploy", "newrelic:notice_deployment"

namespace :deploy do
  desc "kill ruby processes"
  task "stop", roles: :app, except: {no_release: true} do
    run "killall ruby || true"
    run "sleep 1"
  end

  desc "start ruby processes with foreman"
  task "start", roles: :app, except: {no_release: true} do
    run "RAILS_ENV=#{rails_env} nohup bundle exec foreman start > #{shared_path}/log/foreman.log &"
  end

  desc "restart ruby processes with foreman"
  task "restart", roles: :app, except: {no_release: true} do
    stop
    start
  end

  deploy.task :cold do
    deploy.update
    deploy.start
  end

   task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
  end
  # after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
end

namespace :mongoid do
  desc "Link the mongoid config in the release_path"
  task :symlink do
    run "test -f #{release_path}/config/mongoid.yml || ln -s #{shared_path}/mongoid.yml #{release_path}/config/mongoid.yml"
  end

  desc "Create MongoDB indexes"
  task :index do
    run "cd #{release_path} && RAILS_ENV=production bundle exec rake db:mongoid:create_indexes", :once => true
  end
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
