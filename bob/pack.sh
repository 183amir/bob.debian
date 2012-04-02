#!/bin/bash
# Andre Anjos <andre.anjos@idiap.ch>
# Mon 02 Apr 2012 09:58:12 AM CEST

# Creates a new version of the base tarball with the databases
orig="idiap-bob-44ecddcbf32ceae226998df1f65ccec7584de51e"
bob="bob_1.0rc1-git-44ecddcb"
db_version="nightlies/last"

if [ -e ${bob}.orig.tar.gz ]; then
  echo "error: a version of '${bob}.orig.tar.gz' exists"
  exit 1
fi

tar xfz ${orig}.tar.gz
mv ${orig} ${bob}.orig
cd ${bob}.orig
./bin/dbdownload.py --version=${db_version} --verbose
if [ $? != 0 ]; then
  echo "error: could not download databases"
  exit 1
fi
cd ..
tar cfz ${bob}.orig.tar.gz ${bob}.orig
rm -rf ${bob}.orig

echo "New package at: ${bob}.orig.tar.gz"
