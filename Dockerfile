FROM ruby:3.2.5-alpine

RUN apk --no-cache add \
    build-base \
    linux-headers \
    postgresql-dev \
    nodejs \
    yarn \
    tzdata \
    file \
    git \
    curl \
    bash \
    libxml2-dev \
    libxslt-dev \
    && gem install bundler

WORKDIR /app
    
COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
