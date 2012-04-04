#!/bin/bash 
# Andre Anjos <andre.anjos@idiap.ch>
# Sun Apr  1 23:05:41 CEST 2012

# Creates a new debian package for Bob

# Configure here your parameters for the package you are building
version="1.0.0"
package="bob_${version}"
ppa_iteration="3"
gpg_key="A2170D5D"
include_source="-sd" #-sd = w/o source; -sa = with souce

if [ ! -e ${package}.orig.tar.gz ]; then
  wget http://www.idiap.ch/software/bob/packages/bob-${version}.tar.gz;
  tar xfz bob-${version}.tar.gz;
  rm -f bob-${version}.tar.gz;
  mv bob-${version} ${package}.orig;
  tar cfz ${package}.orig.tar.gz ${package}.orig;
fi

date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today                   : ${date}"
echo "Bob version             : ${version}"

#for distro in precise; do
for distro in oneiric natty maverick lucid; do
  ppa_version="${version}-0~ppa${ppa_iteration}~${distro}1"
  echo "Biometrics PPA version  : ${ppa_version}"

  echo "Generating source packages for Ubuntu '${distro}'..."
  tar xfz ${package}.orig.tar.gz;
  cp -a ${package}.orig ${package};
  cd ${package}
  cp -r ../debian .
  sed -i -e "s/@VERSION@/${version}/g" debian/rules
  sed -i -e "s/@VERSION@/${version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  debuild -k${gpg_key} ${include_source} -S;
  cd ..
  rm -rf ${package}
done
