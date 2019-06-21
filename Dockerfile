# Decidim Application Dockerfile
#
# This is an image to be used with docker-compose, to develop Decidim (https://decidim.org) locally.
#
#

# Starts with a clean ruby image from Debian (slim)
FROM ruby:2.5.3

ENV PHANTOMJS_VERSION 2.1.1
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2
RUN tar -xjvf phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2
RUN cp phantomjs-${PHANTOMJS_VERSION}-linux-x86_64/bin/phantomjs /usr/bin/phantomjs

# Installs system dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    imagemagick \
    libpq-dev \
    nodejs

# Sets workdir as /app
RUN mkdir /app
WORKDIR /app

# Installs bundler dependencies
ENV BUNDLE_PATH=/app/vendor/bundle \
  BUNDLE_BIN=/app/vendor/bundle/bin \
  BUNDLE_JOBS=5 \
  BUNDLE_RETRY=3 \
  GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Copy all the code to /app
ADD . /app
