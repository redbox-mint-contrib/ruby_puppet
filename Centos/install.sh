#!/bin/bash
#
# Bootstrap script for Ruby-Puppet on CENTOS
# usage requires creation of variables:
#    RUBY_VERSION
#    PUPPET_VERSION
# e.g., export RUBY_VERSION=2.0.0-p598
# e.g., export PUPPET_VERSION=3.8.4
#  tested on Centos 6.7 x86_64 and Centos 7.2.1511 x86_64
#
usage() {
	if [ `whoami` != 'root' ]; 
		then echo "this script must be executed as root" && exit 1;
	fi
}
usage

echo "running this script requires RUBY_VERSION and PUPPET_VERSION variables set."
echo "Trying ruby version..."
[ -z $RUBY_VERSION ] && exit 1
echo "Trying puppet version..."
[ -z $PUPPET_VERSION ] && exit 1

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
 gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
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

addToPath() {
	for p in $*; do
	  echo $PATH | grep -q $p || echo "adding $p/bin to PATH..." && export PATH="${PATH}:$p/bin"
	  grep -q $p /root/.bashrc || echo "updating PATH with $p" && echo "export PATH=\$PATH:$p/bin" >> /root/.bashrc 
	done
}

reset
install_rvm

# setup and load rvm
bash /etc/profile.d/rvm.sh
addToPath '/usr/local/rvm'

install_ruby
addToPath "/usr/local/rvm/rubies/ruby-${RUBY_VERSION}"
echo "ruby install completed"
install_puppet
echo "puppet install completed"
echo "Installation complete. To activate ruby (and puppet), either log out/in, or source /root/.bashrc"

## add all installed rubies to root path (so available immediately)
ln -s /usr/local/rvm/rubies/ruby-${RUBY_VERSION}/bin/* /usr/bin/

