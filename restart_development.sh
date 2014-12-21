bundle exec thin stop
bin/delayed_job stop
bundle exec thin start -d
bin/delayed_job start
tail -f log/development.log
