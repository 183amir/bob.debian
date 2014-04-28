#!/bin/bash
# Andre Anjos <andre.anjos@idiap.ch>
# Sun Apr  1 23:05:41 CEST 2012

# Creates a new debian package for Bob

# Configure here your parameters for the package you are building
soversion="2.0"
version="${soversion}.0a1"
package="bob_${version}"
ppa_iteration="2"
gpg_key="A2170D5D"; # Andre
#gpg_key="E0CE7EF8"; # Laurentes
source_shipped=1; #if you set this to 1, all changes will ship with srcs
#source_shipped=0; #if you set this to 0, all changes will ship w/o srcs
#distros="trusty";
distros="trusty saucy quantal precise lucid";

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

for distro in ${distros}; do
  ppa_version="${version}-0~ppa${ppa_iteration}~${distro}1"
  echo "Biometrics PPA version  : ${ppa_version}"

  echo "Generating source packages for Ubuntu '${distro}'..."
  tar xfz ${package}.orig.tar.gz;
  cp -a ${package}.orig ${package};
  cd ${package}
  cp -r ../debian .
  for specific in control compat rules patches bob.install bob-dev.install; do
    if [ -e ../os.files/${specific}.${distro} ]; then
      echo "Overriding with specific '${specific}' for '${distro}'..."
      set CPOPT=-L -f
      [ -d ../os.files/${specific}.${distro} ] && CPOPT="${CPOPT} -r"
      cp ${CPOPT} ../os.files/${specific}.${distro} debian/${specific}
    fi
  done
  sed -i -e "s/@VERSION@/${version}/g;s/@SOVERSION@/${soversion}/g" debian/rules
  sed -i -e "s/@VERSION@/${version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  if [ "${source_shipped}" = "1" ]; then
    debuild -k${gpg_key} -sa -S;
    source_shipped=0;
  else
    debuild -k${gpg_key} -sd -S;
  fi
  cd ..
  rm -rf ${package}
done
