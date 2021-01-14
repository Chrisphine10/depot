# config valid for current version and patch releases of Capistrano
lock "~> 3.15.0"

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
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
# Change these
server '35.246.80.61', port: 22, user: 'depot',  roles: [:web, :app, :db], primary: true

set :repo_url,        'git@github.com:Chrisphine10/depot.git'
set :application,     'depot'
set :user,            'depot'
set :puma_threads,    [4, 16]
set :puma_workers,    0


# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
#set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :ssh_options, { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa) }

set :linked_files, %w{config/database.yml}


## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}


namespace :nginx do
  desc 'setup config for nginx server ( how to use: cap stage_environment nginx:set_config )'
  task :set_config do
    on roles(:web) do
      execute :sudo, "rm -f /etc/nginx/sites-enabled/*.conf"
      execute :sudo, "ln -s #{fetch(:deploy_to)}/current/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}.conf"
      execute :sudo, "ln -s #{fetch(:deploy_to)}/shared/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}.conf"
      execute :sudo, "/usr/sbin/nginx -s quit || true"
      execute :sudo, "/usr/sbin/nginx"
    end
  end

  desc "Reload nginx ( how to use: cap stage_environment nginx:reload )"
  task :reload do
    on roles(:web) do
      execute :sudo, "service nginx reload"
    end
  end
end
namespace :log do
  desc "Watch tailf environment log"
  task :tailf do
    stream("tailf /depot/apps/#{application}/current/log/#{stage}.log")
  end
end
# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
