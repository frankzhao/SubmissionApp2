kill -9 `pgrep unicorn`
bin/delayed_job stop

RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production rails s
RAILS_ENV=production bin/delayed_job -n 4 start
echo "Done."
