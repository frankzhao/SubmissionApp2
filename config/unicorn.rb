# config/unicorn.rb
is_prod = ENV['RAILS_ENV'] == 'production'
if is_prod
  APP_ROOT = ENV["APP_ROOT"]
else
  APP_ROOT = Rails.root.to_s
end


working_directory APP_ROOT
pid "#{APP_ROOT}/tmp/pids/unicorn.pid"

if !is_prod
  worker_processes 1
  timeout 60
else
  worker_processes 6
  timeout 60
  preload_app true
end

listen 3000
stdout_path "#{APP_ROOT}/log/unicorn.log"
stderr_path "#{APP_ROOT}/log/unicorn.log"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
end