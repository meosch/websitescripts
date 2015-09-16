#!/bin/bash

# What is our webroot folder called?  docroot? httpdocs? public_html?
webroot="public_html"

# Pull down latest copy of Wetkit.
./distro.pull.sh

GIT_ROOT=$(git rev-parse --show-toplevel)
cd $GIT_ROOT

echo "Removing webroot"
rm -rf ${webroot}

echo "Building Wetkit profile"
drush make -y scripts/build-wetkit-profile.make ${webroot} --no-gitinfofile

# Remove .gitignore files that are undesired.
rm ${webroot}/profiles/wetkit/.gitignore
rm ${webroot}/profiles/wetkit/libraries/Leaflet/.gitignore

echo "Symlinking sites directory to ${webroot}/sites"
cd ${webroot}
rm -rf sites
ln -s ../sites
echo "Symlinking .htaccess ${webroot}/.htaccess"
rm .htaccess
ln -s ../.htaccess
echo "Symlinking robots.txt to ${webroot}/robots.txt"
rm robots.txt
ln -s ../robots.txt
