#!/bin/bash 
# Andre Anjos <andre.anjos@idiap.ch>
# Fri 30 Mar 2012 15:42:02 CEST

# Creates a new debian package for Blitz++ based on Laurent's instructions
# and findings.

# Configure here your parameters for the package you are building
base_blitz_version="0.10-July3"
ppa_iteration="1"
#gpg_key="E0CE7EF8" #LES
gpg_key="A2170D5D" #AA
source_shipped=0; #if you set this to 0, all changes will ship w/o srcs

# 1) Clone the mercurial repository
if [ ! -e blitz++_0.10-July3.orig.tar.gz ]
then 
  wget http://downloads.sourceforge.net/project/blitz/blitz/Blitz++\ 0.10/blitz-0.10.tar.gz
  mv blitz-0.10.tar.gz blitz++_0.10-July3.orig.tar.gz
fi
tar -xvzf blitz++_0.10-July3.orig.tar.gz
echo "Cloning done."
rm -r blitz.clone
mv blitz-0.10 blitz.clone
#hg_version=1902
date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today                   : ${date}"
blitz_version="${base_blitz_version}"
echo "Blitz++ version: ${blitz_version}"

for distro in raring quantal precise oneiric natty maverick lucid; do
  ppa_version="3:${blitz_version}-0~ppa${ppa_iteration}~${distro}1"
  echo "Biometrics PPA version  : ${ppa_version}"
  echo "Generating source packages for Ubuntu '${distro}'..."
  cp -r blitz.clone blitz++_${blitz_version}.orig
  #cd blitz++_${blitz_version}.orig
  #rm -rf .hg .hgtags .cvsignore
  #if [ ! -e ../blitz++_${base_blitz_version}${hg_version}.orig.tar.gz ]; then
  #  tar -cvzf ../blitz++_${base_blitz_version}${hg_version}.orig.tar.gz *
  #fi
  #cd ..
  cp -r blitz++_${blitz_version}.orig blitz++_${blitz_version}
  cd blitz++_${blitz_version}
  cp -r ../debian .
  sed -i -e "s/@VERSION@/${blitz_version}/g" debian/rules
  sed -i -e "s/@VERSION@/${blitz_version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  if [ "${source_shipped}" = "1" ]; then
    debuild -k${gpg_key} -sa -S;
    source_shipped=0;
  else
    debuild -k${gpg_key} -sd -S;
  fi
  cd ..
  rm -rf blitz++_${blitz_version}.orig blitz++_${blitz_version}
done
