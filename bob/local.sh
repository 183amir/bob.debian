#!/bin/bash 
# Andre Anjos <andre.anjos@idiap.ch>
# Sun Apr  1 23:05:41 CEST 2012

# Creates a new debian package for Bob

# Configure here your parameters for the package you are building
bob="bob-1.0beta-git-44ecddcb"
ppa_iteration="2"

# Name used by the packaging system
tarball="${bob}.orig.tar.gz"

rm -rf ${bob} ${bob}.orig #cleanup
tar xfz ${bob}.tar.gz
mv ${bob} ${bob}.orig

date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today                   : ${date}"
echo "Bob version             : ${bob_version}"

#for distro in precise oneiric natty maverick lucid; do
for distro in precise; do
  ppa_version="${bob}-0~ppa${ppa_iteration}~${distro}1"
  rm -rf ${package}
  echo "Biometrics PPA version  : ${ppa_version}"

  echo "Generating source packages for Ubuntu '${distro}'..."
  cp -r ${package}.orig ${package}
  cd ${package}
  cp -r ../debian .
  sed -i -e "s/@VERSION@/${bob_version}/g" debian/rules
  sed -i -e "s/@VERSION@/${bob_version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  debuild -us -uc -b;
  cd ..
done
