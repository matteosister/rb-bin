FROM ruby:2.2

RUN adduser ubuntu
RUN chown ubuntu:ubuntu /usr/local/bundle -R
USER ubuntu

WORKDIR /code
COPY . /code
RUN bundle install

VOLUME /code