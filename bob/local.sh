#!/bin/bash 
# Andre Anjos <andre.anjos@idiap.ch>
# Sun Apr  1 23:05:41 CEST 2012

# Creates a new debian package for Bob

# Configure here your parameters for the package you are building
soversion="1.0"
version="${soversion}.2"
package="bob_${version}"
ppa_iteration="1"
distros=precise

if [ ! -e ${package}.orig.tar.gz ]; then
  if [ ! -e bob-${version}.tar.gz ]; then
    wget http://www.idiap.ch/software/bob/packages/bob-${version}.tar.gz;
  fi
  tar xfz bob-${version}.tar.gz;
  rm -f bob-${version}.tar.gz;
  mv bob-${version} ${package}.orig;
  tar cfz ${package}.orig.tar.gz ${package}.orig;
fi

date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today                   : ${date}"
echo "Bob version             : ${version}"

for distro in ${distros}; do
  ppa_version="${version}-0~ppa${ppa_iteration}~${distro}1"
  echo "Biometrics PPA version  : ${ppa_version}"

  echo "Generating binary packages for Ubuntu '${distro}'..."
  [ ! -e ${package}.orig ] && tar xfz ${package}.orig.tar.gz;
  [ -e ${package} ] && rm -rf ${package};
  cp -a ${package}.orig ${package};
  cd ${package}
  cp -r ../debian .
  if [ -e ../os.files/rules.${distro} ]; then
    echo "Overriding with special rules for '${distro}'..."
    cp -L -f ../os.files/rules.${distro} debian/rules
  fi
  sed -i -e "s/@VERSION@/${version}/g;s/@SOVERSION@/${soversion}/g" debian/rules
  sed -i -e "s/@VERSION@/${version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  debuild -us -uc -b;
  cd ..
done
