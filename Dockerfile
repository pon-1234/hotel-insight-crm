FROM ruby:2.6.3-buster

ENV APP_PATH=/var/app \
  BUNDLE_VERSION=1.17.3 \
  BUNDLE_PATH=/usr/local/bundle/gems \
  RAILS_ENV=production \
  RACK_ENV=production \
  RAILS_LOG_TO_STDOUT=true \
  RAILS_SERVE_STATIC_FILES=true

RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list \
  && sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list \
  && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    gnupg2 \
    default-libmysqlclient-dev \
    default-mysql-client \
    libxml2-dev \
    libxslt1-dev \
    imagemagick \
    tzdata \
    less \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://nodejs.org/dist/v12.22.12/node-v12.22.12-linux-x64.tar.gz -o /tmp/node-v12.22.12-linux-x64.tar.gz \
  && tar -xzf /tmp/node-v12.22.12-linux-x64.tar.gz -C /usr/local --strip-components=1 \
  && npm install -g yarn \
  && rm -f /tmp/node-v12.22.12-linux-x64.tar.gz

RUN gem install bundler --version "$BUNDLE_VERSION" \
  && rm -rf $GEM_HOME/cache/*

WORKDIR $APP_PATH

COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' \
  && bundle _${BUNDLE_VERSION}_ install -j 4 --retry 3

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

RUN SECRET_KEY_BASE=dummy REDIS_URL=redis://localhost:6379/1 bundle exec rails assets:precompile

EXPOSE 8080

CMD ["sh", "-c", "bundle exec rails server -b 0.0.0.0 -p ${PORT:-8080}"]
