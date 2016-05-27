#!/bin/bash -l

set -e

unset RUBYOPT
export PATH=./bin:$PATH

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

echo 'Creating RPM'
echo '----'
cd ..
/usr/local/rpm_builder/create-rails-rpm $artifact_name $artifact_name $version_number
