
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
done


for dir in $feed_dirs; do 
	mkdir -p $dir 
	chgrp feedsync $dir
	chmod 775 $dir
done
