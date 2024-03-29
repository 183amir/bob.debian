#!/bin/bash
# Laurent El Shafey <laurent.el-shafey@idiap.ch>
# Fri Mar 30 20:31:10 2012 +0200

# Creates a new debian package for VLFeat based on Laurent

# Configure here your parameters for the package you are building
vlfeat_version="0.9.18"
ppa_iteration="1"
#gpg_key="E0CE7EF8" #LES
#gpg_key="A2170D5D" #AA
gpg_key="5EEC234C"; #Pavel
source_shipped=1; #if you set this to 0, all changes will ship w/o srcs
subdir=vlfeat-${vlfeat_version}
filename=${subdir}.tar.gz
distro=`lsb_release -c -s`
distro_id=`lsb_release -i -s`
distro_release=`lsb_release -r -s`

# 1) Get the latest release source code
if [ ! -e ${filename} ]; then
  wget http://www.vlfeat.org/download/vlfeat-${vlfeat_version}.tar.gz
fi

if [ -d ${subdir} ]; then rm -rf ${subdir}; fi

tar -xvzf vlfeat-${vlfeat_version}.tar.gz

if [ -e vlfeat_${vlfeat_version}.orig.tar.gz ]; then
  rm -f vlfeat_${vlfeat_version}.orig.tar.gz;
fi
cp vlfeat-${vlfeat_version}.tar.gz vlfeat_${vlfeat_version}.orig.tar.gz

if [ -d vlfeat.clone ]; then rm vlfeat.clone; fi
mv vlfeat-${vlfeat_version} vlfeat.clone

date=`date +"%a, %d %b %Y %H:%M:%S %z"`
echo "Today          : ${date}"
echo "VLFeat version : ${vlfeat_version}"
echo "Distribution   : ${distro_id} ${distro_release} (${distro})"

for distro in trusty raring quantal precise lucid vivid; do
  ppa_version="${vlfeat_version}-0~ppa${ppa_iteration}~${distro}1"
  echo "Biometrics PPA version  : ${ppa_version}"

  echo "Generating source packages for Ubuntu '${distro}'..."
  cp -r vlfeat.clone vlfeat_${vlfeat_version}
  cd vlfeat_${vlfeat_version}
  cp -r ../debian .
  sed -i -e "s/@VERSION@/${vlfeat_version}/g" debian/rules
  sed -i -e "s/@VERSION@/${vlfeat_version}/g;s/@PPA_VERSION@/${ppa_version}/g;s/@DATE@/${date}/g;s/@DISTRIBUTION@/${distro}/g" debian/changelog
  if [ "${source_shipped}" = "1" ]; then
    debuild -k${gpg_key} -sa -S;
    source_shipped=0;
  else
    debuild -k${gpg_key} -sd -S;
  fi
  cd ..
  rm -rf vlfeat_${vlfeat_version}
done

rm -rf vlfeat.clone
rm vlfeat-${vlfeat_version}.tar.gz
