# frozen_string_literal: true

require 'dotenv'

# Don't change these unless you know what you're doing
set :pty,             false
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :init_system,     :systemd

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}
set :linked_files, %w[.env config/master.key]
append :linked_dirs, '.bundle'

# Default value for linked_dirs is []
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets public/uploads config/secrets public/.well-known]

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
set :keep_releases, 2

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

before 'deploy:assets:precompile', 'deploy:yarn_install'

namespace :deploy do
  # Trigger the task before publishing

  desc 'Run rake yarn:install'
  task :yarn_install do
    on roles(:app) do
      within release_path do
        execute("cd #{release_path} && yarn install --check-files")
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      invoke 'deploy'
    end
  end

  desc 'Restart sidekiq'
  task :sidekiq_restart do
    on roles(:app) do
      execute "cd #{current_path}"
      execute :sudo, :systemctl, :restart, 'lineinsight-sidekiq'
    end
  end


  desc 'Restart puma'
  task :puma_restart do
    on roles(:app) do
      execute "cd #{current_path}"
      execute :sudo, :systemctl, :restart, 'lineinsight-puma'
    end
  end

  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
end

namespace :db do
  desc 'Resets DB without create/drop'
  task :reset do
    on primary :db do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'db:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1'
        end
      end
    end
  end
end

after :deploy, 'deploy:puma_restart'
after :deploy, 'deploy:sidekiq_restart'
# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
