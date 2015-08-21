#!/bin/bash
# Andre Anjos <andre.anjos@idiap.ch>
# Sun Apr  1 23:05:41 CEST 2012
# Pavel Korshunov <pavel.korshunov@idiap.ch>
# Sun Aug 16 22:42:40 CEST 2015

# Creates a new debian package for Bob 2.0 and higher

# Configure here your parameters for the package you are building
soversion="2.0"
#commit="1e7c846c08"
#version="${soversion}.0+g${commit}"
version="${soversion}.4"
package="bob_${version}"
#change ppa_iteration for every new update on ppa launchpad
ppa_iteration="4"
distro=`lsb_release -c -s`
distro_id=`lsb_release -i -s`
distro_release=`lsb_release -r -s`

if [ ! -e ${package}.orig.tar.gz ]; then
  echo "${package}.orig.tar.gz does not exist, so we are creating it"
  if [ ! -e bob-${version}.zip ]; then
    #download bob from the Pypi morror on debian (not MD5 checksums here)
    echo "bob-${version}.zip does not exist, so downloading it from debian's mirro on pypi.."
    wget http://pypi.debian.net/bob/bob-${version}.zip
  fi
  #we need to create a folder named in a certain way, so debian packaging
  #environment can understand it
  unzip bob-${version}.zip
  mv -f bob-${version} ${package}.orig
  rm -f bob-${version}.zip

  #download all dependencies and put inside our future tarball
  cd ${package}.orig
  echo "running pip install with --download option to get all dependancies
  locally"
  #cat ../external_requirements.txt requirements.txt > tmp_req.txt
  while read req; do
    echo "Installing \`${req}'..."
    #pip install --download="." -v -v -v --no-use-wheel --no-deps --no-compile --find-links="." --install-option sdist "${req}"
    IFS=' ' read -a parsed_req <<< "${req}"
    wget http://pypi.debian.net/${parsed_req[0]}/${parsed_req[0]}-${parsed_req[2]}.zip
    status=$?
    echo "pip returned status = ${status}"
    if [  "${status}" != 0  ]; then
      echo "Installation of package ${req} failed; aborting"
      exit ${status};
    fi
  done <requirements.txt
  #remove all binary wheels, as we do not need them
  #echo "delete binary wheels downloaded by pip"
  #rm -fr *.whl
  cd ..

  #tarball the folder with all the sources
  tar cfz ${package}.orig.tar.gz ${package}.orig;
fi

#make sure date generates days of the week in English (the Locale on your Machine)
date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today                   : ${date}"
echo "Bob version             : ${version}"

ppa_version="${version}-0~ppa${ppa_iteration}~${distro}1"
echo "Biometrics PPA version  : ${ppa_version}"

#copies all debian files related to the distribution from os.files folder
#into debian folder
echo "Generating binary packages for Ubuntu '${distro}'..."
[ ! -e ${package}.orig ] && tar xfz ${package}.orig.tar.gz;
[ -e ${package} ] && rm -rf ${package};
cp -a ${package}.orig ${package};
cd ${package}
cp -r ../debian .
for specific in control rules patches bob.install bob-dev.install; do
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
sed -i -e "s/@VERSION@/${version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
debuild -us -uc -b;
cd ..
