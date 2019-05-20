BUILD_DIRS="gvm-libs openvas-scanner gvmd openvas-smb "
SDIR=$(pwd)
for dir in $BUILD_DIRS; do 

	cd $dir 
	rm -rf build
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
	mkdir $dir
	chgrp feedsync $dir
	chmod 775 $dir
done



useradd feedsync
sudo -u feedsync /usr/local/bin/greenbone-nvt-sync 
sudo -u feedsync /usr/local/sbin/greenbone-scapdata-sync 
sudo -u feedsync /usr/local/sbin/greenbone-certdata-sync 


cp /usr/local/share/doc/openvas-scanner/redis_3_2.conf /etc/redis/redis.conf
