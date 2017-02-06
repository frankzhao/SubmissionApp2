FROM ruby:2.4.0-slim

LABEL VERSION=0.0.1-dev

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client build-essential git libpq-dev \
    && apt-get clean

RUN gem install rails -v 5.0.1 --no-ri --no-rdoc 

RUN git clone https://github.com/frankzhao/SubmissionApp2 --branch rails_upgrade submissionapp2
RUN cd submissionapp2 && bundle install

WORKDIR submissionapp2

# TODO run migrations, assets
ENTRYPOINT ["thin", "start"]

EXPOSE 3000

