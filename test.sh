#!/bin/bash -l

set -e

export PATH=./bin:$PATH
export RAILS_ENV=test

echo 'Untar precompiled assets'
echo '-------------------'
tar -xzvf ../precompiled-assets.tgz

echo 'Running Database Schema Load'
echo '-------------------'
RAILS_ENV=test bundle exec rake db:schema:load

echo 'Running RSpec tests'
echo '-------------------'
bundle exec rspec spec --format html --out tmp/spec.html --format RspecJunitFormatter --profile --format progress --deprecation-out log/rspec_deprecations.txt
