#!/bin/bash 
# Andre Anjos <andre.anjos@idiap.ch>
# Sun Apr  1 23:05:41 CEST 2012

# Creates a new debian package for Bob

# Configure here your parameters for the package you are building
version="1.0rc1-git-44ecddcb"
package="bob_${version}"
ppa_iteration="2"
gpg_key="A2170D5D"
include_source="-sd" #-sd = w/o source; -sa = with souce

rm -rf ${package} ${package}.orig #cleanup
tar xfz ${package}.orig.tar.gz

date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today                   : ${date}"
echo "Bob version             : ${version}"

#for distro in precise oneiric natty maverick lucid; do
for distro in precise; do
  ppa_version="${version}-0~ppa${ppa_iteration}~${distro}1"
  echo "Biometrics PPA version  : ${ppa_version}"

  echo "Generating source packages for Ubuntu '${distro}'..."
  cp -a ${package}.orig ${package}
  cd ${package}
  cp -r ../debian .
  sed -i -e "s/@VERSION@/${version}/g" debian/rules
  sed -i -e "s/@VERSION@/${version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  debuild -k${gpg_key} ${include_source} -S;
  cd ..
  rm -rf ${package}
done

rm -rf ${package}.orig
