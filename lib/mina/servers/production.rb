# FreeBSD
namespace :env do
  task :production => [:environment] do
    set :domain,              '123.123.123.123'
    set :deploy_to,           '/home/app_user/app'
    set :sudoer,              'sudoer_user'
    set :user,                'app_user'
    set :group,               'app_user'
    # set :rvm_path,          '/usr/local/rvm/scripts/rvm'   # we don't use that. see below.
    set :services_path,       '/usr/local/etc/rc.d'          # where your God and Unicorn service control scripts will go
    set :nginx_path,          '/usr/local/etc/nginx'
    set :deploy_server,       'production'                   # just a handy name of the server
    invoke :defaults                                         # load rest of the config
    # invoke :"rvm:use[#{rvm_string}]"                       # since my prod server runs 1.9 as default system ruby, there's no need to run rvm:use
  end
end
