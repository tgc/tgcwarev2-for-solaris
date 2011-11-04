#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gmp
version=5.0.1
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/gmp/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
[ "$_os" = "sunos56" ] && triplet="${arch}-sun-solaris2.6"
[ "$_os" = "sunos57" ] && triplet="${arch}-sun-solaris2.7"
configure_args="--host=$triplet --build=$triplet $configure_args --enable-cxx"
# otherwise configure tests will fail since they don't respect LDFLAGS :(
export LD_LIBRARY_PATH="$prefix/lib"


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
    doc AUTHORS COPYING COPYING.LIB NEWS README

    # Compat libraries
    setdir ${prefix}/${_libdir}
    ${__tar} -cf - libgmp.so.3* | (cd ${stagedir}${prefix}/${_libdir}; ${__tar} -xf -)
    compat gmp 4.2.4 1 5
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
