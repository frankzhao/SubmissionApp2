git pull
bundle exec thin stop
bundle exec thin start --ssl --ssl-verify --ssl-key-file ssl/varese.key --ssl-cert-file ssl/varese.crt -e production -d
