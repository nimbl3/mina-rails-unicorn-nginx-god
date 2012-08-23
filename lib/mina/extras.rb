namespace :config do
  desc "Symlink all configs"
  task :link do
    set :sudo, true
    invoke :'god:link'
    invoke :'unicorn:link'
    invoke :'nginx:link'
  end

  desc "Upload all configs"
  task :upload do
    invoke :'god:upload'
    invoke :'unicorn:upload'
    invoke :'nginx:upload'
  end
end

task :setup_extras do
  queue 'echo "-----> Create configs path"'
  queue echo_cmd "mkdir -p #{config_path}"

  queue 'echo "-----> Create shared paths"'
  shared_paths.each do |p|
    queue echo_cmd "mkdir -p #{deploy_to}/#{shared_path}/#{p}"
  end

  queue 'echo "-----> Create PID and Sockets paths"'
  queue echo_cmd "mkdir -p #{pids_path} && chmod +rw #{pids_path}"
  queue echo_cmd "mkdir -p #{sockets_path} && chmod +rw #{sockets_path}"
end

task :health do
  queue 'ps aux | grep -v grep | grep -v bash | grep -e "bin\/god" -e "unicorn_rails" -e "mongod" -e "nginx" -e "redis" -e "STAT START   TIME COMMAND" -e "bash"'
end

task :sudo do
  set :sudo, true
end

###############################################################################
# Helpers
###############################################################################

# Parse config template, echo() them on the server, and check if command succeeded
def upload_template(desc, tpl, destination)
  contents = parse_template(tpl)
  queue %{echo "-----> Put #{desc} file to #{destination}"}
  queue %{echo "#{contents}" > #{destination}}
  queue check_exists(destination)
end

# Parse config template and escape some characters for safe bash echo()
def parse_template(file)
  erb("#{config_templates_path}/#{file}.erb").gsub('"','\\"').gsub('`','\\\\`').gsub('$','\\\\$')
end

check_response = 'then echo "----->   SUCCESS"; else echo "----->   FAILED"; fi'

# Self-explanatory
def check_exists(destination)
  %{if [[ -s "#{destination}" ]]; #{check_response}}
end

def check_ownership(u, g, destination)
  %{
    oll=(`ls -l #{destination}`)
    if [[ -s "#{destination}" ]] && [[ ${oll[2]} == '#{u}' ]] && [[ ${oll[3]} == '#{g}' ]]; #{check_response}
  }
end

def check_exec_and_ownership(u, g, destination)
  %{
    oll=(`ls -l #{destination}`)
    if [[ -s "#{destination}" ]] && [[ -x "#{destination}" ]] && [[ ${oll[2]} == '#{u}' ]] && [[ ${oll[3]} == '#{g}' ]]; #{check_response}
  }
end

def check_symlink(destination)
  %{if [[ -h "#{destination}" ]]; #{check_response}}
end

# Override default Mina ssh_command to be able to log in as sudoer, when needed
module Mina
  module Helpers
    def ssh_command
      args = domain!
      args = if sudo? && sudoer?
        "#{sudoer}@#{args}"
      elsif user?
        "#{user}@#{args}"
      end
      args << " -i #{identity_file}" if identity_file?
      args << " -p #{port}" if port?
      args << " -t"
      "ssh #{args}"
    end
  end
end
