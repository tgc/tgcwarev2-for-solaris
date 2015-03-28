#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=sudo
version=1.8.12
pkgver=2
source[0]=http://www.sudo.ws/sudo/dist/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=sudo-1.8.12-netlibs-link.patch
patch[1]=sudo-1.8.12-ssp-link.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--sysconfdir=/usr/tgcware/etc --with-man --with-all-insults)

reg prep
prep()
{
    generic_prep
    setdir source
    ${__gsed} -i "/^install_uid/ s/0/$(id -u)/" Makefile.in
    ${__gsed} -i "/^install_gid/ s/0/$(id -u)/" Makefile.in
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
    ${__mv} ${stagedir}${prefix}/share/examples/sudo ${stagedir}${prefix}/${_vdocdir}/examples
    ${__rmdir} ${stagedir}${prefix}/share/examples
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
