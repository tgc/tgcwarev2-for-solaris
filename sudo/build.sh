#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=sudo
version=1.8.6p5
pkgver=3
source[0]=http://www.sudo.ws/sudo/dist/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=sudo-1.8.6p5-fix-ssp-link.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args="$configure_args --sysconfdir=/usr/tgcware/etc --with-man"

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

reg check
check()
{
    generic_check
}

reg install
install()
{
    generic_install DESTDIR
    ${__mv} ${stagedir}${prefix}/share/doc/sudo ${stagedir}${prefix}/${_vdocdir}
}

reg pack
pack()
{
    lprefix=${prefix#/*}
    topinstalldir=/
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
