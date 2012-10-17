#!/bin/bash
# Andre Anjos <andre.anjos@idiap.ch>
# Mon 02 Apr 2012 09:58:12 AM CEST

# Creates a new version of the base tarball with the databases
commit="7b064026"
version="1.1.1b1"
#bob="bob_${version}+g${commit}.orig"
bob="bob_${version}.orig"

if [ -e ${bob}.tar.gz ]; then
  echo "error: a version of '${bob}.orig.tar.gz' exists"
  exit 1
fi

if [ ! -e ${bob} ]; then
  echo "Downloading package contents from github..."
  wget --no-check-certificate https://github.com/idiap/bob/tarball/${commit} -O - | tar xz

  mv idiap-bob-* ${bob}
else
  echo "Re-using previously downloaded package contents"
fi

tar cfz ${bob}.tar.gz ${bob}
rm -rf ${bob}

echo "New package at: ${bob}.tar.gz"
