#!/bin/bash 
# Andre Anjos <andre.anjos@idiap.ch>
# Fri 30 Mar 2012 15:42:02 CEST

# Creates a new debian package for Blitz++ based on Laurent's instructions
# and findings.

# Configure here your parameters for the package you are building
base_blitz_version="0.10-hg"
ppa_iteration="3"
gpg_key="E0CE7EF8"

# 1) Clone the mercurial repository
if [ -e blitz.clone ]; then
  echo "Updating Blitz++ Mercurial Repository..."
  cd blitz.clone
  hg pull
  cd ..
  echo "Updating done."
else
  echo "Cloning Blitz++ Mercurial Repository..."
  hg clone http://blitz.hg.sourceforge.net:8000/hgroot/blitz/blitz blitz.clone
  echo "Cloning done."
fi

cd blitz.clone
hg_version=`hg log -l1 | head -n1 | awk '{print $2}' | sed -e 's/:.*$//g'`
cd ..

date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today                   : ${date}"
blitz_version="${base_blitz_version}${hg_version}"
echo "Blitz++ version checkout: ${blitz_version}"

for distro in precise oneiric natty maverick lucid; do
  ppa_version="2:${blitz_version}-0~ppa${ppa_iteration}~${distro}1"
  echo "Biometrics PPA version  : ${ppa_version}"
  echo "Generating source packages for Ubuntu '${distro}'..."
  cp -r blitz.clone blitz++_${blitz_version}.orig
  cd blitz++_${blitz_version}.orig
  rm -rf .hg .hgtags .cvsignore
  if [ ! -e ../blitz++_${base_blitz_version}${hg_version}.orig.tar.gz ]; then
    tar -cvzf ../blitz++_${base_blitz_version}${hg_version}.orig.tar.gz *
  fi
  cd ..
  cp -r blitz++_${blitz_version}.orig blitz++_${blitz_version}
  cd blitz++_${blitz_version}
  cp -r ../debian .
  sed -i -e "s/@VERSION@/${blitz_version}/g" debian/rules
  sed -i -e "s/@VERSION@/${blitz_version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  debuild -k${gpg_key} -sa -S;
  cd ..
  rm -rf blitz++_${blitz_version}.orig blitz++_${blitz_version}
done
