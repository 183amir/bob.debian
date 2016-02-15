#!/bin/bash
# Andre Anjos <andre.anjos@idiap.ch>
# Sun Apr  1 23:05:41 CEST 2012
# Pavel Korshunov <pavel.korshunov@idiap.ch>
# Sun Aug 18 22:42:40 CEST 2015

# Builds a debian package locally for a specified bob package
# this script is meant to use for verification and debugging purposes

# Configure here your parameters for the package you are building
soversion="2.1"
version="${soversion}.$2"
subversion=1
package="$1_${version}"
#change ppa_iteration for every new update on ppa launchpad
ppa_iteration="0"
#change your GPG/PGP key here
gpg_key="5EEC234C"; #Pavel
#gpg_key="A2170D5D"; # Andre
#gpg_key="E0CE7EF8"; # Laurentes
#source_shipped=1; #if you set this to 1, all changes will ship with srcs
distros="trusty";
#distros="precise vivid wily";

function preparedistr {
  name=$1
  version=$2
  source_shipped=0; #if you set this to 0, all changes will ship w/o srcs
  curpackage="${name}_${version}"
  #make sure date generates days of the week in English (the Locale on your
  #Machine)
  date=`date +"%a, %d %b %Y %H:%M:%S %z"`
  echo "Today                   : ${date}"
  echo "$1 version             : $2"

  echo "${curpackage}"
  #copies all debian files related to the distribution from os.files folder
  #into debian folder
  for distro in ${distros}; do
    ppa_version="${version}-${subversion}~ppa${ppa_iteration}~${distro}1"
    echo "Biometrics PPA version  : ${ppa_version}"

    echo "Generating source packages for Ubuntu '${distro}'..."
    tar xfz ${curpackage}.orig.tar.gz;
    cp -a ${curpackage}.orig ${curpackage};
    cd ${curpackage}
    cp -r ../debian .
    for specific in control compat rules patches bob.install bob-dev.install; do
      if [ -e ../os.files/${specific}.${distro} ]; then
        echo "Overriding with specific '${specific}' for '${distro}'..."
        set CPOPT=-L -f
        [ -d ../os.files/${specific}.${distro} ] && CPOPT="${CPOPT} -r"
        rm -rf debian/${specific}
        cp ${CPOPT} ../os.files/${specific}.${distro} debian/${specific}
      fi
    done
    #update all versions and date in the changelog file, so that correct debian
    #packages are created. Make sure your Day of the week in Locale is in English
    sed -i -e "s/@PACKAGE@/${name}/g;s/@VERSION@/${version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
    # update the name of the package in control file and add dependencies
    sed -i -e "s/@PACKAGE@/${name}/g" debian/control
    dependencies=`cat ../dependencies/${name}`
    sed -i -e "s/@BOBDEPENDENCIES@/${dependencies}/g" debian/control

    # local build
    #debuild -us -uc -b;
    # build for PPA
    debuild -i -k${gpg_key} -sd -S;

    cd ..
    rm -fr ${curpackage}
  done
}


#create tarball of the folder with all the sources only if it does not exist
if [ ! -e ${package}.orig.tar.gz ]; then
  tar cfz ${package}.orig.tar.gz ${package}.orig;
fi


#tarball the folder with all the sources
#tar cfz ${package}.orig.tar.gz ${package}.orig;

# create debian package for the bob meta package
preparedistr $1 ${version}

