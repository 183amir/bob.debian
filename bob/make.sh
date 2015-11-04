#!/bin/bash
# Andre Anjos <andre.anjos@idiap.ch>
# Sun Apr  1 23:05:41 CEST 2012
# Pavel Korshunov <pavel.korshunov@idiap.ch>
# Sun Aug 18 22:42:40 CEST 2015

# Creates a new debian package for Bob

# Configure here your parameters for the package you are building
soversion="2.0"
version="${soversion}.5"
# you can inscreas this subversion when the source tarball has changes
subversion=9
package="bob_${version}"
#change ppa_iteration for every new update on ppa launchpad
ppa_iteration="4"
#change your GPG/PGP key here
gpg_key="5EEC234C"; #Pavel
#gpg_key="A2170D5D"; # Andre
#gpg_key="E0CE7EF8"; # Laurentes
#source_shipped=1; #if you set this to 1, all changes will ship with srcs
#distros="vivid";
distros="precise";
#distros="trusty";
#distros="trusty saucy raring quantal precise lucid";

# create a distribution-specific PPA package and sign it with a gpg key
function preparedistr {
  source_shipped=0; #if you set this to 0, all changes will ship w/o srcs
  pn=${1}; #package name
  pv=${2}; #package version
  curpackage="${pn}_${pv}"
  #make sure date generates days of the week in English (the Locale on your
  #Machine)
  date=`date +"%a, %d %b %Y %H:%M:%S %z"`
  echo "Today                   : ${date}"
  echo "$1 version             : $2"

  echo "${curpackage}"
  #copies all debian files related to the distribution from os.files folder
  #into debian folder
  for distro in ${distros}; do
    ppa_version="${pv}-${subversion}~ppa${ppa_iteration}~${distro}1"
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
    sed -i -e "s/@PACKAGE@/${pn}/g;s/@VERSION@/${pv}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
    # update the name of the package in control file and add dependencies
    sed -i -e "s/@PACKAGE@/${pn}/g" debian/control
    dependencies=`cat ../dependencies/${pn}`
    sed -i -e "s/@BOBDEPENDENCIES@/${dependencies}/g" debian/control

    # build and sign the resulted package
    if [ "${source_shipped}" = "1" ]; then
      debuild -i -k${gpg_key} -sa -S;
      source_shipped=0;
    else
      debuild -i -k${gpg_key} -sd -S;
    fi

    # comment above debuild and uncomment this, if want to build packages locally
#    debuild -us -uc -b;

    cd ..
    rm -fr ${curpackage}
  done
}


# create .orig folder if it does not exist yet
if [ ! -e ${package}.orig ]; then
  if [ ! -e bob-${version}.zip ]; then
   #download bob from the Pypi morror on debian (not MD5 checksums here)
   echo "bob-${version}.zip does not exist, so downloading it from debian's mirro on pypi.."
   wget http://pypi.debian.net/bob/bob-${version}.zip
  fi

  #we need to create a folder named in a certain way, so debian packaging
  #environment can understand it
  unzip -q bob-${version}.zip
  mv -f bob-${version} ${package}.orig
#  rm -f bob-${version}.zip

  #create tarball of the folder with all the sources only if it does not exist
  if [ ! -e ${package}.orig.tar.gz ]; then
    tar cfz ${package}.orig.tar.gz ${package}.orig;
  fi
fi

#download all dependencies and create a separate package for each of them
#cd ${package}
echo "Downloading packages from debian mirror of pypi using wget..."
while read req; do
  echo "Processing \`${req}'..."
  IFS=' ' read -a parsed_req <<< "${req}"
  # define names for subpackages of bob
  zip_name=${parsed_req[0]}-${parsed_req[2]}
  package_name=${parsed_req[0]}_${parsed_req[2]}

  # create tarball only if it does not exist already
  if [ ! -e ${package_name}.orig.tar.gz ]; then
    wget -q http://pypi.debian.net/${parsed_req[0]}/${zip_name}.zip
    status=$?
    echo "wget returned status = ${status}"
    if [  "${status}" != 0  ]; then
      echo "Download of package ${req} failed; aborting"
      exit ${status};
    fi

   # create -orig folder from downloaded zip file
    unzip -q ${zip_name}.zip
    mv -f ${zip_name} ${package_name}.orig
    rm -f ${zip_name}.zip
    # create tarball from orig folder
    tar cfz ${package_name}.orig.tar.gz ${package_name}.orig
  fi

  # call function to prepare debian package
  preparedistr ${parsed_req[0]} ${parsed_req[2]}

done <${package}.orig/requirements.txt


# create the final debian package for the bob meta package
preparedistr bob ${version}

