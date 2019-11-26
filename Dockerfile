FROM ruby:2.6-alpine

RUN apk add --no-cache build-base
RUN gem install nokogiri

WORKDIR /usr/src/app
