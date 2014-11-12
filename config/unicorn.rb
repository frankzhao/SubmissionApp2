rails_env = ENV['RAILS_ENV'] || 'production'
dev_root = '/Users/frank/dev/submissionapp2'

if rails_env == 'development'
  app_root = dev_root
elsif rails_env == 'production'
  app_root = '/home/comp1100/submissionapp2'
end

STDOUT.write "Starting in " + rails_env + " from " + app_root

listen 3000
listen "127.0.0.1:3000"
worker_processes 2
timeout 60

# PID
pid "#{app_root}/tmp/pids/unicorn.pid"

# Log files
stderr_path "#{app_root}/log/unicorn.stderr.log"
stdout_path "#{app_root}/log/unicorn.stdout.log"
