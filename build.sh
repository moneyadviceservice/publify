#!/bin/bash -l

set -e

unset RUBYOPT
export PATH=./bin:$PATH

version_number=${GO_PIPELINE_LABEL-0}
revision=`git rev-parse HEAD`
build_date=`date +'%Y-%m-%d %H:%M %z'`

function create_rails_rpm {
  service_name="mas-$1"
  shift
  version_number=$1
  shift
  options="$@"
  source_dir=$(pwd)

  (
    cd ..
    rm -Rf build
    mkdir -p build/srv build/etc/init.d
    cp $source_dir/etc/after-install build/
    cp $source_dir/etc/service-script build/etc/init.d/$service_name
    rsync -va --exclude='.git*' --include=bin/rails --exclude=bin/* --exclude=features/ --exclude=log/ --exclude=spec/ --exclude=tmp/ $source_dir build/srv
    cd build
    fpm --after-install after-install --version $version_number --name $service_name --prefix=/ -a all -t rpm -s dir $options srv etc
  )
}

echo 'Cleaning temporary files'
echo '-----------------------'

echo 'Removing precompiled assets'
rm -rf public/assets

echo 'Removing packaged gems'
rm -rf vendor/cache

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

cat > public/version <<EOT
{
  "version":"$version_number",
  "buildDate":"$build_date",
  "gitRevision":"$revision"
}
EOT

echo 'Precompiling assets'
echo '----'
RAILS_ENV=production RAILS_GROUPS=assets rake assets:precompile

echo 'Running Bundle package'
echo '----'
bundle package --all

echo 'Uploading assets'
echo '----'
/usr/local/bin/upload-blog-assets.sh $(pwd)/public ${ASSET_CONTAINER}

echo 'Creating RPM'
echo '----'
create_rails_rpm $artifact_name $version_number --rpm-attr 0755,mas,service:/srv/blog/public/cache 
