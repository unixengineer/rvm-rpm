#!/bin/bash
set +x
RUBY_VERSION="${RUBY_VERSION:-2.7.1}"
RUBYGEMS_VERSION="${RUBYGEMS_VERSION:-3.1.4}"
YAML_VERSION="${YAML_VERSION:-0.1.6}"
RVM_VERSION="${RVM_VERSION:-1.29.10}"
# When moving to Artifactory, change the URL accordingly
RVM_DOWNLOAD_URL="https://github.com/rvm/rvm/archive/${RVM_VERSION}.tar.gz"
RUBYGEMS_DOWNLOAD_URL="http://production.cf.rubygems.org/rubygems/rubygems-${RUBYGEMS_VERSION}.tgz"
RUBY_DOWNLOAD_URL="https://rvm_io.global.ssl.fastly.net/binaries/centos/7/x86_64/ruby-${RUBY_VERSION}.tar.bz2"
YAML_DOWNLOAD_URL="http://pyyaml.org/download/libyaml/yaml-${YAML_VERSION}.tar.gz"

###
RVM_ARCHIVE_PATH="/usr/local/rvm/archives"
# Install the yum dependencies to build rvm
yum -y install wget sudo java-11-openjdk-devel git rpm-build redhat-rpm-config chrpath readline-devel zlib-devel libyaml-devel libffi-devel openssl-devel which sqlite-devel
# Uncomment this if you think your docker build env does not have the right tools
#yum clean all && yum -y groupinstall "Development tools"

# Now install RVM
curl ${RVM_DOWNLOAD_URL} -o rvm-stable.tar.gz
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
curl ${RUBY_DOWNLOAD_URL} -o ${RVM_ARCHIVE_PATH}/ruby-${RUBY_VERSION}.tar.bz2
curl ${RUBYGEMS_DOWNLOAD_URL} -o ${RVM_ARCHIVE_PATH}/rubygems-${RUBYGEMS_VERSION}.tgz
curl ${YAML_DOWNLOAD_URL} -o ${RVM_ARCHIVE_PATH}/yaml-${YAML_VERSION}.tar.gz
set -x 


source /etc/profile.d/rvm.sh
rvm autolibs read-fail

echo "Here is where we start the process ....."
rvm mount -r /usr/local/rvm/archives/ruby-${RUBY_VERSION}.tar.bz2
rvm install ${RUBY_VERSION} --rubygems ${RUBYGEMS_VERSION}
rvm use ${RUBY_VERSION} --default
rvm list
ruby --version
gem install fpm --no-document


