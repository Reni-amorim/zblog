# config valid for current version and patch releases of Capistrano
lock "~> 3.18.0"

# Change these
server '15.229.43.153', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url, "git@github.com:Reni-amorim/zblog.git"
set :application, "zblog"



# qualquer coisa
##################################################################################################
#############################3 TRY
#set :rbenv_prefix, '/deploy/bin/rbenv exec'


#set :rbenv_type, :system
set :rbenv_ruby,      '3.0.6'
set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }

#set :rbenv_ruby_dir,  '/home/deploy/.rbenv/versions/3.0.6'
#set :default_env, { 'RBENV_ROOT' => '/home/deploy/.rbenv', 'PATH' => '$RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH' }

#set :default_env, { 'RBENV_ROOT' => "$HOME/.rbenv" }
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} RBENV_ROOT=#{fetch(:rbenv_path)}"
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
##################### try
#set :rbenv_map_bins, %w{rake gem bundle ruby rails}




#set :default_env, { 'RBENV_ROOT' => '/home/deploy/.rbenv', 'PATH' => '$RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH' }

#set :default_env, {
#  'RBENV_ROOT' => '/home/deploy/.rbenv',
#  'PATH' => '$RBENV_ROOT/shims:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/deploy/.rvm/bin:$PATH'
#}


##########################################################################################################
# If using Digital Ocean's Ruby on Rails Marketplace framework, your username is 'rails'
set :user,            'deploy'
set :puma_threads,    [4, 16]
set :puma_workers,    0

# Don't change these unless you know what you're doing
#set bundle jobs
set :bundle_jobs, 1

set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

append :rbenv_map_bins, 'puma', 'pumactl'

## Defaults:
# set :scm,           :git
# set :branch,        :main
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

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

  before 'deploy:starting', 'puma:make_dirs'
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do

      # Update this to your branch name: master, main, etc. Here it's main
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  
  
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  namespace :deploy do
    desc 'Generate Puma systemd service configuration'
    task :generate_puma_systemd_config do
      on roles(:app) do
        within current_path do
          execute :puma, :systemd, :config, 'TEMPLATE_PATH', 'OUTPUT_PATH'
        end
      end
    end
  end
  


  desc 'Restart application'
    task :restart do
      on roles(:app), in: :sequence, wait: 5 do
        invoke 'puma:restart'
      end
  end

 
  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  # after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma

########################################
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure