BUILD_DIRS="gvm-libs openvas-scanner gvmd openvas-smb "
SDIR=$(pwd)
for dir in $BUILD_DIRS; do 

	cd $dir 
	rm -rf build
	mkdir build
	cd build
	cmake .. || exit
	make || exit
	make install || exit
	cd $SDIR
done
