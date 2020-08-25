#!/bin/bash

RUBY_VERSION="2.7.1"
RUBY_DOWNLOAD_URL="https://ftp.ruby-lang.org/pub/ruby"
RUBYGEMS_VERSION="2.4.6"
RUBYGEMS_DOWNLOAD_URL="http://production.cf.rubygems.org/rubygems"
YAML_VERSION="0.1.6"
YAML_DOWNLOAD_URL="http://pyyaml.org/download/libyaml"
RVM_ARCHIVE_PATH="/usr/local/rvm/archives"
# Install the yum dependencies to build rvm
yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
yum -y install wget sudo java-11-openjdk-devel git rpm-build redhat-rpm-config chrpath readline-devel zlib-devel libyaml-devel libffi-devel openssl-devel which sqlite-devel
yum clean all && yum -y groupinstall "Development tools"

# Now install RVM
curl -sSL https://github.com/rvm/rvm/tarball/stable -o rvm-stable.tar.gz
mkdir rvm && cd rvm
tar --strip-components=1 -xzf ../rvm-stable.tar.gz
./install --auto-dotfiles # RVM will be installed in /usr/local/rvm
if [ -f /etc/profile.d/rvm.sh ]
then
	source /etc/profile.d/rvm.sh
else
	echo "RVM Installation encountered an error"
	exit 1
fi

[[ -d ${RVM_ARCHIVE_PATH} ]] || mkdir -p ${RVM_ARCHIVE_PATH}
curl -sSL ${RUBY_DOWNLOAD_URL}/ruby-${RUBY_VERSION}.tar.bz2 -o ${RVM_ARCHIVE_PATH}/ruby-${RUBY_VERSION}.tar.bz2
curl -sSL ${RUBYGEMS_DOWNLOAD_URL}/rubygems-${RUBYGEMS_VERSION}.tgz -o ${RVM_ARCHIVE_PATH}/rubygems-${RUBYGEMS_VERSION}.tgz
curl -sSL ${YAML_DOWNLOAD_URL}/yaml-${YAML_VERSION}.tar.gz -o ${RVM_ARCHIVE_PATH}/yaml-${YAML_VERSION}.tar.gz

ls -la ${RVM_ARCHIVE_PATH}/

#echo rvm_archives_path=${RVM_ARCHIVE_PATH} | tee -a ~/.rvmrc
#echo rvm_archives_path=${RVM_ARCHIVE_PATH} | tee -a /etc/rvmrc
source /etc/profile.d/rvm.sh
rvm autolibs read-fail
#rvm requirements
echo "" > ~/.rvm/gemsets/default.gems
echo "" > ~/.rvm/gemsets/global.gems
env|sort

echo "Here is where we start the process ....."
rvm mount -r /usr/local/rvm/archives/ruby-${RUBY_VERSION}.tar.bz2
rvm install ${RUBY_VERSION} --rubygems ${RUBYGEMS_VERSION} --verify-downloads 2 --disable-binary
rvm use ${RUBY_VERSION}

