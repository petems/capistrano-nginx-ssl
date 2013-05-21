require 'capistrano/ext/puppetize'
require 'capistrano/ext/multistage'

set :application, "capistrano-nginx-ssl"
set :app_host_name, :application

#To save having to setup SSH keys for github, we're just gonna copy over...
set :repository, "."
set :scm, :none
set :deploy_via, :copy

set :default_stage, "vagrant"
set :stages, %w(vagrant staging production)

set :owner, ENV['USER']

before 'deploy', 'deploy:check'

depend :remote, :command, "puppet"

default_run_options[:pty] = true

# Override default tasks which are not relevant to a non-rails app.
namespace :deploy do
  task :migrate do
    puts "    not doing migrate because not a Rails application."
  end
  task :finalize_update do
    puts "    not doing finalize_update because not a Rails application."
  end
  task :start do ; end
  task :stop do ; end
  task :restart do ; end
end