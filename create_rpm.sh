#!/bin/bash

# This script will build a RPM from the files in the current directory, given that there is a rpm/file.spec
# Its primary purpose is to be used by Jenkins

if [ $UID == 0 ]; then
  echo "Please do not build RPM packages as root"
  exit 1
fi

set -e
set -x

specfile="rvm-ruby.spec"
name=`grep -P '^Name:\s+' $specfile |awk '{print $2}'`
commitdate=`git log -1 --format="%ct"`
version=`grep -P '^Version:\s+' $specfile |awk '{print $2}'`.$commitdate
#release=`grep -P '^Release:\s+' rpm/$specfile |awk '{print $2}'`
gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
rm -rf rpmbuild
mkdir -p rpmbuild/{BUILD,RPMS,SOURCES/$name-$version,SPECS,SRPMS,tmp}
cp -a $specfile rpmbuild/SPECS
sed -i "s/^[\t ]*Version:.*\$/Version: ${version}/" rpmbuild/SPECS/$specfile
#tar --exclude-vcs --exclude='rpmbuild' --exclude='rpm' -cp * | (cd rpmbuild/SOURCES/$name-$version ; tar xp)

pushd rpmbuild/SOURCES
#tar cf $name-$version.tar $name-$version  # Best not to use cpu on our small ec2 instances
#sed -i "s/^[\t ]*Source0:.*/Source0: $name-$version.tar/g" rpmbuild/SPECS/*.spec
#sed -i "s/^[\t ]*%setup[\t ]\+-n[\t ]\+.*/%setup -n $name-$version/g" rpmbuild/SPECS/*.spec
popd

rpmbuild --define "_topdir %(pwd)/rpmbuild" -ba rpmbuild/SPECS/$specfile
