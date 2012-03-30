#!/bin/bash 
# Laurent El Shafey <laurent.el-shafey@idiap.ch>
# Fri Mar 30 20:31:10 2012 +0200

# Creates a new debian package for VLFeat based on Laurent

# Configure here your parameters for the package you are building
vlfeat_version="0.9.14"
ppa_iteration="3"
gpg_key="E0CE7EF8"

# 1) Clone the mercurial repository
wget http://www.vlfeat.org/download/vlfeat-${vlfeat_version}.tar.gz
tar -xvzf vlfeat-${vlfeat_version}.tar.gz
cp vlfeat-${vlfeat_version}.tar.gz vlfeat_${vlfeat_version}.orig.tar.gz
mv vlfeat-${vlfeat_version} vlfeat.clone


date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today                   : ${date}"
echo "VLFeat version          : ${vlfeat_version}"

for distro in precise oneiric natty maverick lucid; do
  ppa_version="${vlfeat_version}-0~ppa${ppa_iteration}~${distro}1"
  echo "Biometrics PPA version  : ${ppa_version}"

  echo "Generating source packages for Ubuntu '${distro}'..."
  cp -r vlfeat.clone vlfeat_${vlfeat_version}
  cd vlfeat_${vlfeat_version}
  cp -r ../debian .
  sed -i -e "s/@VERSION@/${vlfeat_version}/g" debian/rules
  sed -i -e "s/@VERSION@/${vlfeat_version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  debuild -k${gpg_key} -sa -S;
  cd ..
  rm -rf vlfeat_${vlfeat_version} 
done

rm -rf vlfeat.clone
rm vlfeat-${vlfeat_version}.tar.gz
