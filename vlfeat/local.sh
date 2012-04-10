#!/bin/bash 
# Andre Anjos <andre.anjos@idiap.ch>
# Fri 30 Mar 2012 15:42:02 CEST

# Creates a new debian package for VLFeat based on Laurent's instructions
# and findings.

# Configure here your parameters for the package you are building
vlfeat_version="0.9.14"
ppa_iteration="3"
gpg_key="E0CE7EF8"

# 1) Get the latest release source code
wget http://www.vlfeat.org/download/vlfeat-${vlfeat_version}.tar.gz
tar -xvzf vlfeat-${vlfeat_version}.tar.gz
cp vlfeat-${vlfeat_version}.tar.gz vlfeat_${vlfeat_version}.orig.tar.gz
mv vlfeat-${vlfeat_version} vlfeat.clone

date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today                   : ${date}"
echo "VLFeat version          : ${vlfeat_version}"

for distro in unknown; do
  rm -rf vlfeat.local *.build
  ppa_version="${vlfeat_version}-0~ppa${ppa_iteration}~${distro}1"
  echo "Biometrics PPA version  : ${ppa_version}"

  echo "Generating source packages for Ubuntu '${distro}'..."
  cp -r vlfeat.clone vlfeat.local
  cd vlfeat.local
  cp -r ../debian .
  sed -i -e "s/@VERSION@/${vlfeat_version}/g" debian/rules
  sed -i -e "s/@VERSION@/${vlfeat_version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  debuild -us -uc -b
  cd ..
done
