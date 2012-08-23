$:.unshift './lib'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

require 'mina/defaults'
require 'mina/extras'
require 'mina/god'
require 'mina/unicorn'
require 'mina/nginx'
require "mina/servers/production"
require "mina/servers/vagrant"

###########################################################################
# Common settings for all servers
###########################################################################

set :app,                'cool_app'
set :repository,         'https://github.com/user_name/repo_name.git'
set :deploy_server,      'production' #=> production, staging, demo, vagrant, you name it
set :keep_releases,       9999        #=> I like to keep all my releases

###########################################################################
# Tasks
###########################################################################

task :environment do
  queue %{
    echo "-----> Using RVM environment '#{rvm_string!}'"
    #{echo_cmd %{source #{rvm_path!}}} || exit 1
    #{echo_cmd %{rvm use "#{rvm_string!}"}} || exit 1
  }
end

desc "Deploys the current version to the server."
task :deploy => [:environment] do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    # invoke :'rails:db_migrate'         # I'm using MongoDB, not AR, so I don't need those
    # invoke :'rails:assets_precompile'  # I don't really like assets pipeline

    to :launch do
      invoke :'unicorn:restart'
    end
  end
end
