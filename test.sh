#!/bin/bash -l

set -e

export PATH=./bin:$PATH
export RAILS_ENV=test

echo 'Cleaning temporary files'
echo '-----------------------'

echo 'Removing SimpleCov, log and tmp files'
rm -rf coverage log/* tmp/*

echo 'Removing bower cache and components'
echo '-----------------------'
bower cache clean
rm -rf vendor/assets/bower_components

echo 'Running bundler'
echo '-----------------------'
bundle install

echo 'Running bowndler'
echo '-----------------------'
bowndler update --production --config.interactive=false

echo 'Running Database Schema Load'
echo '-------------------'
cp config/database.yml.postgres config/database.yml
RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load db:migrate

echo 'Running RSpec tests'
echo '-------------------'
bundle exec rspec spec --format html --out tmp/spec.html --profile --format progress --deprecation-out log/rspec_deprecations.txt
