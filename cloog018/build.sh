#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=cloog
version=0.18.0
pkgver=1
source[0]=ftp://gcc.gnu.org/pub/gcc/infrastructure/${topdir}-${version}.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Get gcc arch setting
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.cpu

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args="$configure_args --disable-static --with-gcc-arch=$gcc_arch --with-isl=system --with-gmp=system"

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
    docs_for libcloog-isl4 LICENSE README
    ${__mv} ${stagedir}${prefix}/${_bindir}/cloog ${stagedir}${prefix}/${_bindir}/cloog-isl
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
