#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# The concept of "method" registering and the logic that implements it was shamelessly
# stolen from jhlj's Compile.sh script :)
#
# Check the following 4 variables before running the script
topdir=openssl
version=0.9.6k
pkgver=1
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=openssl-0.9.6k-soversion.patch
patch[1]=openssl-0.9.6k-Configure.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

abbrev_ver=$(echo $version|sed -e 's/\.//g')

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
pkgname=SBossl$abbrev_ver
name="OpenSSL - Secure Socket Layer"
pkgcat="application"
pkgvendor="http://www.openssl.org"
pkgdesc="Toolkit implementing SSL v2/v3 and TLS v1"

pkgname_lib=SBossl$abbrev_ver"lib"
name_lib="OpenSSL - Secure Socket Layer"
pkgcat_lib="library"
pkgvendor_lib="http://www.openssl.org"
pkgdesc_lib="Toolkit implementing SSL v2/v3 and TLS v1"

# 0.9.6(a-?) is sover 2
# 0.9.7(a-?) is sover 4
baseversion=0.9.6
sover=2

lib_stage=$BUILDPKG_BASE/$topdir/stage.lib

# Define script functions and register them
METHODS=""
reg() {
    METHODS="$METHODS $1"
}

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    setdir source
    ./config --prefix=$prefix --openssldir=$prefix/ssl shared
    $MAKE_PROG
    $MAKE_PROG -C test apps tests
}

reg install
install()
{
    setdir source
    $MAKE_PROG INSTALL_PREFIX=$stagedir install build-shared
    setdir $stagedir$prefix/lib
    liblist="libssl libcrypto"
    for i in $liblist
    do
	mv $i.so.$baseversion $i.so.$version
	rm -f $i.so.$sover
	rm -f $i.so
	ln -s $i.so.$version $i.so.$sover
	ln -s $i.so.$sover $i.so
    done
    rmdir $stagedir$prefix/ssl/lib
    mv $stagedir$prefix/ssl/man $stagedir$prefix
    setdir $stagedir$prefix/man
    for j in $(ls -1d man?)
    do
 	cd $j
	for x in *
	do
	    mv $x $x"ssl"
	done
	cd ..
    done
}

reg pack
pack()
{
    MV=mv
    # Split up the stagedir
    mkdir -p $lib_stage$prefix
    $MV $stagedir$prefix/lib $lib_stage$prefix
    
    # Create runtime package
    echo "P $pkgname_lib	$name_lib" > $metadir/depend
    generic_pack

    usedepend=0
    $MV $stagedir $stagedir.1
    $MV $lib_stage $stagedir
    pkgname=$pkgname_lib
    name=$name_lib
    pkgcat=$pkgcat_lib
    pkgvendor=$pkgvendor_lib
    pkgdesc=$pkgdesc_lib

    distfile=$topdir-lib-$version-$pkgver.sb-$os-$cpu-$pkgdirdesig
    generic_pack

    $MV $stagedir.1 $stagedir
    setdir source
    clean stage
}

reg distclean
distclean()
{
    # depend is created by build.sh so make sure
    # it's removed by distclean
    META_CLEAN="$META_CLEAN depend"

    clean distclean
    pkgname=$pkgname_lib
    clean meta
}

###################################################
# No need to look below here
###################################################

reg all
all()
{
    for METHOD in $METHODS 
    do
	case $METHOD in
	     all*|*clean) ;;
	     *) $METHOD
		;;
	esac
    done

}

reg
usage() {
    echo Usage $0 "{"$(echo $METHODS | tr " " "|")"}"
    exit 1
}

OK=0
for METHOD in $*
do
    METHOD=" $METHOD *"
    if [ "${METHODS%$METHOD}" == "$METHODS" ] ; then
	usage
    fi
    OK=1
done

if [ $OK = 0 ] ; then
    usage;
fi

for METHOD in $*
do
    ( $METHOD )
done
