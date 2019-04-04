#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=flex
version=2.6.4
pkgver=1
source[0]=https://github.com/westes/$topdir/releases/download/v${version}/$topdir-$version.tar.lz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I/$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"

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
    ${__mv} ${stagedir}${prefix}/${_docdir}/flex ${stagedir}${prefix}/${_vdocdir}
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
