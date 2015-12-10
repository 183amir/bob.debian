#!/bin/bash
# Pavel Korshunov <pavel.korshunov@idiap.ch>
# Mon Oct 26 19:32:40 CEST 2015

# run dput for all packages and upload them to PPA

# get the list of all packages

# Configure here your parameters for the packages you want to upload to ppa
soversion="2.0"
version="${soversion}.6"
subversion=0
package="bob_${version}"
#change ppa_iteration for every new update on ppa launchpad
ppa_iteration="1"
#distros="trusty";
#distros="precise";
#distros="vivid"
distros="precise vivid wily";

tar xfz ${package}.orig.tar.gz

# send each package that is in the requirements files of bob package
while read req; do
  echo "Processing \`${req}'..."
  IFS=' ' read -a parsed_req <<< "${req}"
  wget -q http://pypi.debian.net/${parsed_req[0]}/${parsed_req[0]}-${parsed_req[2]}.zip
  status=$?
  echo "pip returned status = ${status}"
  if [  "${status}" != 0  ]; then
    echo "Installation of package ${req} failed; aborting"
    exit ${status};
  fi

  # do it for each specified distribution
  for distro in ${distros}; do
    ppa_name="${parsed_req[0]}_${parsed_req[2]}-${subversion}~ppa${ppa_iteration}~${distro}1_source.changes"
    echo "Sending to PPA  : ${ppa_name}"
    dput ppa:biometrics/bob ${ppa_name}
  done
done <${package}.orig/requirements.txt

# now send the meta package bob
for distro in ${distros}; do
  ppa_name="${package}-${subversion}~ppa${ppa_iteration}~${distro}1_source.changes"
  echo "Sending to PPA  : ${ppa_name}"
  dput ppa:biometrics/bob ${ppa_name}
done


