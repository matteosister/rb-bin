FROM ruby:2.2

WORKDIR /code
COPY . /code
RUN bundle install

VOLUME /code