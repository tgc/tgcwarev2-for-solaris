#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# The concept of "method" registering and the logic that implements it was shamelessly
# stolen from jhlj's Compile.sh script :)
#
# Check the following 4 variables before running the script
topdir=openssh
version=3.8.1p1
pkgver=1
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${HOME}/buildpkg/scripts/buildpkg.functions

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
pkgname=SBossh
name="OpenSSH portable for Solaris"
pkgvendor="http://www.openssh.org"
pkgdesc="Secure Shell remote access utility"

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
    # Use prngd socket (For Solaris 2.6,7 & 8 without patch 112438)
    #ENTROPY="--with-prngd-socket=/var/run/egd-pool"
    # Use /dev/random (For Solaris 9 & 8 with patch 112438)
    ENTROPY="--without-prngd --without-rand-helper"
    setdir source
    ./configure --prefix=$prefix $ENTROPY --with-default-path=/usr/bin:/usr/local/bin --with-mantype=cat --with-pam --disable-suid-ssh --without-rsh --with-privsep-user=sshd --with-superuser-path=/usr/bin:/usr/sbin:/usr/local/bin --with-lastlog=/var/adm/lastlog --without-zlib-version-check
    $MAKE_PROG
}

reg install
install()
{
    clean stage
    setdir source
    $MAKE_PROG DESTDIR=$stagedir install-nokeys
    strip
    setdir $stagedir$prefix/etc
    for i in *; do mv $i $i.default; done
    cp -p $srcdir/sshd.init $stagedir/usr/local/etc
 }

reg pack
pack()
{
    generic_pack
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
	     all*) ;;
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
