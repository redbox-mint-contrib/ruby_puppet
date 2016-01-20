#!/bin/bash
#
# Bootstrap script for Ruby-Puppet on CENTOS
# usage requires creation of variables:
#    RUBY_VERSION
#    PUPPET_VERSION
#  tested on Centos 6.5 x86_64
#
usage() {
	if [ `whoami` != 'root' ]; 
		then echo "this script must be executed as root" && exit 1;
	fi
}
usage

log_function() {
 printf  -- "At function: %s...\n" $1
}

## remove any existing yum installation
reset() {
 log_function $FUNCNAME
 yum remove -y ruby facter puppet libyaml
}

## install ruby installer, rvm
install_rvm() {
 log_function $FUNCNAME
 gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
 curl -L get.rvm.io | bash -s stable
}

# install modules required for puppet/ruby
install_puppet() {
 log_function $FUNCNAME
 yum install -y augeas-libs augeas-devel compat-readline5 libselinux-ruby git
 gem install ruby-augeas bundler
 gem install puppet -v ${PUPPET_VERSION}
}

reset
install_rvm

#setup and reload rvm
source /etc/profile.d/rvm.sh
rvm autolibs enable
rvm install ruby-${RUBY_VERSION}
rvm use ${RUBY_VERSION} --default
install_puppet

