# SubmissionApp2 Production Setup

Start by cloning the project from [https://github.com/frankzhao/SubmissionApp2](https://github.com/frankzhao/SubmissionApp2) into a directory of your choice.

## Installing Dependecies

Postgres 9.6 is required, so the follow apt repo needs to be added, where `trusty` is replaced by whatever distribution of ubuntu is running.

```shell
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
```

Then install the required packages using

```shell
sudo apt-get install build-essential zlibc zlib1g zlib1g-dev libgmp-dev libxml2 libxml2-dev libxslt1-dev postgresql-9.6 libpq-dev nginx
```

## Setting up Ruby

Install the ruby version manager (rvm). This will install for the current user only, and not system wide, do make sure the user which is running submission app is running this command.

```shell
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
```

rvm may ask for sudo if extra dependencies are required.

Once complete, the script will prompt you with a path to `source` to set some envs, it should look something like this:

```shell
source ~/.rvm/scripts/rvm
```

Run the following commands to install ruby

```shell
rvm install ruby-2.4.0
rvm use ruby-2.4.0 --default
gem install bundler --no-ri --no-rdoc
```

## Installing Gems

Change into the project directory and run

```
bundle install
```

This will install all the required gems, it may take a few minutes

## Setting up project for production

### Postgres

A Postgres role has to be created for the rails application, this can be done in the postgres shell: `psql`

```sql
CREATE ROLE submissionapp WITH CREATEDB LOGIN PASSWORD 'password1';
```

### Environment Variables

The root of the project contains a file: `.env.production` where the environment variables required to run the project can be set.

```
BUGSNAG_API_KEY=        # Key provided for deployment
DB_USERNAME=            # database username
DB_HOSTNAME=localhost   # database host
DB_PASSWORD=            # database password
DB_PORT=5432            # database port
DB_POOL=20              # database connection pool
SKYLIGHT_CONFIG=        # key provided for deployment
SECRET_KEY_BASE=        # output of `rake secret`
```
The value of `SECRET_KEY_BASE` should be the output of the command `rake secret`.

### App Setup

The following steps are required for first time setup:

```
RAILS_ENV=production rake db:create
RAILS_ENV=production rake db:migrate
```

If restoring from a backup, the following command must be run at this point

```
psql -U <username> SubmissionApp_production < dump.sql
```

A password prompt will appear if required. You may get a warning about the schema table, this can be safely ignored.

### Nginx

Nginx is the preferred reverse proxy of choice to handle connections to SubmissionApp. Sample configuration files can be found 
in `install/conf/*.conf` for both HTTPS and HTTP configurations. Update file paths to the correct root path of the SubmissionApp directory, in addition to any SSL certificate paths. Then place the edited file into your nginx configuration directory (usually `/etc/nginx/conf.d/`).

### LaTeX

LaTeX is required for PDF generation of submissions. Specifically, pdflatex and gs is required, along with the `url.sty` package. The recommended LaTeX distribution for Ubuntu is `texlive-latex-base`.

```
apt-get install texlive-full
```
