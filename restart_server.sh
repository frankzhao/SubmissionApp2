bundle exec thin stop
bin/delayed_job stop
cp -r ../ssl .
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake db:seed
bundle exec thin start --ssl --ssl-key-file ssl/varese.key --ssl-cert-file ssl/varese_pem.crt -e production -d
RAILS_ENV=production bin/delayed_job -n 4 start
echo "Done."