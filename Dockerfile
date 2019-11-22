FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    PORT=80

EXPOSE 80

RUN apt-get update -y && \
    apt-get install -y build-essential \
                       curl \
                       git \
                       libpq-dev \
                       ldap-utils \
                       postgresql-client \
                       ruby2.5 ruby2.5-dev \
                       tzdata \
                       # needed to build some gem native extensions:
                       libz-dev \
    && rm -rf /var/lib/apt/lists/*

RUN gem install -N -v 1.17.3 bundler

WORKDIR /opt/conjur-server

COPY Gemfile \
     Gemfile.lock ./

RUN bundle --without test development

COPY . .

RUN ln -sf /opt/conjur-server/bin/conjurctl /usr/local/bin/

ENV RAILS_ENV production

# The Rails initialization expects the database configuration
# and data key to exist. We supply placeholder values so that
# the asset compilation can complete.
RUN DATABASE_URL=postgresql:does_not_exist \
    CONJUR_DATA_KEY=$(openssl rand -base64 32) \
    bundle exec rake assets:precompile

ENTRYPOINT [ "conjurctl" ]
