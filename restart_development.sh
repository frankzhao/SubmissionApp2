# Restart Unicorn in the development environment
kill `cat tmp/pids/unicorn.pid`
RAILS_ENV=development bundle exec unicorn -c config/unicorn.rb -E development -D
tail -f log/development.log
