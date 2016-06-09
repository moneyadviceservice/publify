#!/bin/bash -l

set -e

unset RUBYOPT
export PATH=./bin:$PATH

echo 'Cleaning temporary files'
echo '-----------------------'

echo 'Removing precompiled assets'
rm -rf public/assets

echo 'Removing packaged gems'
rm -rf vendor/cache

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

echo 'Precompiling assets'
echo '----'
RAILS_ENV=production RAILS_GROUPS=assets rake assets:precompile

echo 'Tar precompile assets'
echo '----'
tar -czf precompiled-assets.tgz public/assets
