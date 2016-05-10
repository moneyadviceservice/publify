#!/bin/bash -l

set -e

unset RUBYOPT
export PATH=./bin:$PATH
export BUNDLE_WITHOUT='test:development'

version_number=${GO_PIPELINE_LABEL-0}
revision=`git rev-parse HEAD`
build_date=`date +'%Y-%m-%d %H:%M %z'`

cat > public/version <<EOT
{
  "version":"$version_number",
  "buildDate":"$build_date",
  "gitRevision":"$revision"
}
EOT

echo 'Running Bundle package'
echo '----'
bundle package --all

echo 'Precompiling assets'
echo '----'
RAILS_ENV=production RAILS_GROUPS=assets rake assets:precompile

echo 'Uploading assets'
echo '----'
/usr/local/bin/upload-blog-assets.sh $(pwd)/public

echo 'Creating RPM'
echo '----'
cd ..
/usr/local/rpm_builder/create-rails-rpm $artifact_name $artifact_name $version
