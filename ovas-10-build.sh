#!/bin/bash
# The goal of this script is to build, install and setup Openvas 10 on a brand new
# Debian Stretch build.
INSTALL_ROOT="/usr/local/"
apt update
apt install $(cat packages)

repos="https://github.com/greenbone/gvm-libs \
	https://github.com/greenbone/openvas-scanner \
	https://github.com/greenbone/gvmd \
	https://github.com/greenbone/gsa \
	https://github.com/greenbone/python-gvm \
	https://github.com/greenbone/gvm-tools \
	https://github.com/greenbone/ospd/ \
	https://github.com/greenbone/openvas-smb"

for repo in $repos; do 
	git clone $repo
	if [ $? -ne 0 ]; then
		echo "$repo sync failed."
		exit
	fi
done


SDIR=$(pwd)
for dir in $BUILD_DIRS; do 
	cd $dir 
	if [ -d build ]; then rm -rf build; fi
	mkdir build
	cd build
	cmake .. || exit
	make 
	if [ "$?" != 0 ]; then
		echo "$dir Failed"
		exit
	fi
	make install || exit
	cd $SDIR
done


feed_dirs="/usr/local/var/lib/openvas/plugins /usr/local/var/lib/openvas/gvm/scapdata /usr/local/var/lib/gvm/cert-data"

for dir in $feed_dirs; do 
	mkdir -p $dir
	chgrp feedsync $dir
	chmod 775 $dir
done

# Setup the Feed directory and unpriveledged user
useradd feedsync
passwd -l feedsync
sudo -u feedsync /usr/local/bin/greenbone-nvt-sync 
sudo -u feedsync /usr/local/sbin/greenbone-scapdata-sync 
sudo -u feedsync /usr/local/sbin/greenbone-certdata-sync 

# Copy the redis config 
cp /usr/local/share/doc/openvas-scanner/redis_3_2.conf /etc/redis/redis.conf

# Setup for and Build GSA
sudo apt-get install apt-transport-https
curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

curl --silent --show-error https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
echo "deb https://deb.nodesource.com/node_8.x stretch main" | sudo tee /etc/apt/sources.list.d/nodesource.list

sudo apt-get update
sudo apt-get install nodejs yarn

cd gsa
if [ -d build]; then rm -f build; fi
mkdir build
cd build
cmake ..
if [ $? -ne 0 ]; then echo "GSA cmake filed."; exit ; fi
make
if [ $? -ne 0 ]; then echo "GSA make filed."; exit ; fi
make install
