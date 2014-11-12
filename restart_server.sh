kill `cat tmp/pids/unicorn.pid`
RAILS_ENV='production' bundle exec unicorn -c config/unicorn.rb -E production -D
tail -f log/production.log
