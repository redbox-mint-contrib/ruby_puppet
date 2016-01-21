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
 yum -y install which tar
 log_function $FUNCNAME
 gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
 curl -L get.rvm.io | bash -s stable --auto-dotfiles
}

install_ruby() {
 # zlib require for libyaml (not picked up otherwise by ruby install with autolibs)
 /usr/local/rvm/bin/rvm pkg install zlib
 /usr/local/rvm/bin/rvm reinstall all --force
 /usr/local/rvm/bin/rvm install ruby-${RUBY_VERSION}
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

# setup and load rvm
bash /etc/profile.d/rvm.sh
/usr/local/rvm/bin/rvm autolibs enable

## make rvm immediately available to login shell
grep "rvm" /root/.bashrc || /etc/bash.bashrc >> /root/.bashrc

install_ruby
/usr/local/rvm/bin/rvm use ${RUBY_VERSION} --default
## validate ruby installation
rvm --version || echo "could not find rvm" && exit 1
ruby --version || echo "could not find ruby" && exit 1
gem --version || die "could not find gem" && exit 1
echo "ruby install completed"
install_puppet

