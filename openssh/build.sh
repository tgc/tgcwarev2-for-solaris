#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# build.sh helper functions
. ${BUILDPKG_BASE}/scripts/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=openssh
version=4.3p2
pkgver=1
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Global settings
export LDFLAGS="-R/usr/local/lib -L/usr/local/lib"
export CPPFLAGS="-I/usr/local/include/openssl"
# Use prngd socket (For Solaris 2.6,7 & 8 without patch 112438)
#export ENTROPY="--with-prngd-socket=/var/run/egd-pool"
# Use /dev/random (For Solaris 9 & 8 with patch 112438)
export ENTROPY="--without-prngd --without-rand-helper"
configure_args='--prefix=$prefix --sysconfdir=$prefix/${_sysconfdir} --datadir=$prefix/${_sharedir}/openssh --with-default-path=/usr/bin:/usr/local/bin --with-mantype=cat --with-pam --disable-suid-ssh --without-rsh --with-privsep-user=sshd --with-privsep-path=/var/empty/sshd --with-superuser-path=/usr/bin:/usr/sbin:/usr/local/bin --with-lastlog=/var/adm/lastlog --without-zlib-version-check $ENTROPY'


reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    generic_build
}

reg install
install()
{
    clean stage
    setdir source
    $MAKE_PROG DESTDIR=$stagedir install-nokeys
    setdir ${stagedir}${prefix}/${_sysconfdir}
    for i in *; do ${MV} $i $i.default; done
    ${CP} -p $srcdir/sshd.init $stagedir/usr/local/etc
    custom_install=1
    generic_install
    doc CREDITS ChangeLog INSTALL LICENCE OVERVIEW README README.privsep README.smartcard RFC.nroff TODO WARNING.RNG
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
build_sh $*
