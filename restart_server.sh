bundle exec thin stop
bundle exec thin start --ssl --ssl-key-file ssl/varese.key --ssl-cert-file ssl/varese_pem.crt -e production -d
