#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# The concept of "method" registering and the logic that implements it was shamelessly
# stolen from jhlj's Compile.sh script :)
#
# Check the following 4 variables before running the script
topdir=bzip2
version=1.0.2
pkgver=2
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=bzip2-braindead-solaris-linker.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
name="bzip2"
pkgcat="application"
pkgvendor="http://sources.redhat.com/bzip2/"
pkgdesc="A freely available, high-quality data compressor"

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
    export LD_RUN_PATH=$prefix/lib
    $MAKE_PROG -f Makefile-libbz2_so CFLAGS="-O2 -pipe -mcpu=ultrasparc -mtune=ultrasparc -D_FILE_OFFSET_BITS=64 -fpic -fPIC" all
    $MAKE_PROG -f Makefile CFLAGS="-O2 -pipe -mcpu=ultrasparc -mtune=ultrasparc -D_FILE_OFFSET_BITS=64" all
}

reg install
install()
{
    generic_install PREFIX
    setdir source
    $MKDIR -p $stagedir/share/doc/$topdir-$version
    DOCS="LICENSE CHANGES README README.COMPILATION.PROBLEMS Y2K_INFO"
    for i in $DOCS
    do
	$CP $i $stagedir/share/doc/$topdir-$version
    done
    $CP libbz2.so* $stagedir/lib
    $RM $stagedir/lib/libbz2.a
    setdir $stagedir/lib
    ln -sf libbz2.so.1.0.2 libbz2.so.1.0
    ln -sf libbz2.so.1.0 libbz2.so
}

reg pack
pack()
{
    generic_pack shortroot
}

reg distclean
distclean()
{
    clean distclean
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
