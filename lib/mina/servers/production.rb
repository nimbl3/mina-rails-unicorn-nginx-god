# Production deploy server. 
# My prod server is running FreeBSD, and :pretty term_mode spawns 100% CPU eating zombies.
# Setting :term_mode to :exec seems to help.
task :production do
  set :term_mode,           :exec
  set :domain,              '123.123.123.123'
  set :deploy_to,           '/home/app_user/app'
  set :sudoer,              'sudoer_user'
  set :user,                'app_user'
  set :group,               'app_user'
  set :rvm_path,            '/usr/local/rvm/scripts/rvm'
  set :services_path,       '/usr/local/etc/rc.d'          # where your God and Unicorn service control scripts will go
  set :nginx_path,          '/usr/local/etc/nginx'
  set :deploy_server,       'production'                   # just a handy name of the server
  invoke :defaults                                         # load rest of the config
end
