bundle exec thin stop
bin/delayed_job stop
bundle exec thin start --ssl --ssl-key-file ssl/varese.key --ssl-cert-file ssl/varese_pem.crt -e production -d
bin/delayed_job -n 4 start
