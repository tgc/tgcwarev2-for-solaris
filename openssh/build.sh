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
version=3.6.1p1
pkgver=2
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
    setdir source
    ./configure --prefix=$prefix --with-prngd-socket=/var/run/egd-pool --with-default-path=/usr/bin:/usr/local/bin:/opt/sfw/bin --with-mantype=cat --with-pam --disable-suid-ssh --without-rsh --with-privsep-user=sshd --with-superuser-path=/usr/bin:/usr/sbin:/usr/local/bin
    $MAKE_PROG
}

reg install
install()
{
    clean stage
    setdir source
    $MAKE_PROG DESTDIR=$stagedir install-nokeys
    strip
}

reg pack
pack()
{
    clean meta
    pack_info
    setdir $stagedir$prefix/etc
    for i in *; do mv $i $i.default; done
    cp -p $srcdir/sshd.init $stagedir/usr/local/etc
    setdir $stagedir$prefix
    prototype root bin script
    make_pkg
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
