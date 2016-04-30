#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=mpfr
real_version=3.1.4
version=${real_version}
pkgver=1
source[0]=http://www.mpfr.org/mpfr-current/$topdir-$real_version.tar.xz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
topsrcdir=mpfr-${real_version}

reg prep
prep()
{
    generic_prep
    setdir source
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
    ${__mv} ${stagedir}${prefix}/share/doc/mpfr ${stagedir}${prefix}/${_docdir}/mpfr-$version
    compat mpfr 3.1.1 1 1
    compat mpfr 3.1.2 1 1
    compat mpfr 3.1.2p11 1 1
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
