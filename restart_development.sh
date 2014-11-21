bundle exec thin stop
bundle exec thin start --ssl --ssl-key-file ssl/development.key --ssl-cert-file ssl/development.crt -d
tail -f log/development.log
