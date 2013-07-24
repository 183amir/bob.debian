#!/bin/bash 
# Andre Anjos <andre.anjos@idiap.ch>
# Fri 30 Mar 2012 15:42:02 CEST

# Creates a new debian package for Blitz++ based on Laurent's instructions
# and findings.

# Configure here your parameters for the package you are building
base_blitz_version="0.10"
ppa_iteration="1"
gpg_key="A2170D5D"
distro=`lsb_release -c -s`
distro_id=`lsb_release -i -s`
distro_release=`lsb_release -r -s`

# 1) Clone the mercurial repository
if [ ! -e blitz++_0.10.orig.tar.gz ]
then 
  wget http://downloads.sourceforge.net/project/blitz/blitz/Blitz++\ 0.10/blitz-0.10.tar.gz
  mv blitz-0.10.tar.gz blitz++_0.10.orig.tar.gz
fi
tar -xvzf blitz++_0.10.orig.tar.gz
if [ -d blitz.clone]; then rm -r blitz.clone; fi
mv blitz-0.10 blitz.clone

date=`date +"%a, %d %b %Y %H:%M:%S %z"`
blitz_version="${base_blitz_version}"
echo "Today          : ${date}"
echo "Blitz++ version: ${blitz_version}"
echo "Distribution   : ${distro_id} ${distro_release} (${distro})"

rm -rf blitz.local *.build
ppa_version="3:${blitz_version}-0~ppa${ppa_iteration}~${distro}1"
echo "Biometrics PPA version  : ${ppa_version}"

echo "Generating source packages for Ubuntu '${distro}'..."
cp -r blitz.clone blitz.local
cd blitz.local
cp -r ../debian .
sed -i -e "s/@VERSION@/${blitz_version}/g" debian/rules
sed -i -e "s/@VERSION@/${blitz_version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
debuild -us -uc -b
