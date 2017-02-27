export RAILS_ENV=production
echo "Stopping Existing Servers"
kill -9 `cat ./tmp/pids/unicorn.pid`
kill -9 `cat ./tmp/pids/delayed_job.*`

echo "Running Startup"
bundle exec rake assets:precompile
bundle exec rake db:migrate

echo "Starting Servers"
bundle exec unicorn -c config/unicorn.rb -E production -D
bin/delayed_job -n 4 start

echo "Done."
