#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# The concept of "method" registering and the logic that implements it was shamelessly
# stolen from jhlj's Compile.sh script :)
#
# Check the following 4 variables before running the script
topdir=m4
version=1.4.1
pkgver=2
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=m4-1.4.1-sec.patch
patch[1]=m4-1.4.1-configure.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
name="GNU m4 - Macro processor"
pkgcat="application"
pkgvendor="http://www.gnu.org"
pkgdesc="An implementation of the traditional UNIX macro processor"

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
    autoreconf -f
    generic_build
}

reg install
install()
{
    setdir source
    $MAKE_PROG prefix=$stagedir INSTALL_DATA="/usr/local/bin/install -c -m644" install
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
