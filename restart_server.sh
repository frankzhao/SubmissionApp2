bundle exec thin stop
bin/delayed_job stop
cp -r ../ssl .
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake db:migrate
bundle exec thin start --ssl --ssl-key-file ssl/varese.key --ssl-cert-file ssl/varese_pem.crt -e production -d
bin/delayed_job -n 4 start
