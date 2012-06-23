#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gmp
version=5.0.5
pkgver=3
source[0]=ftp://ftp.sunet.se/pub/gnu/gmp/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
[ "$arch" = "sparc" ] &&  vendor="sun" || vendor="pc"
[ "$_os" = "sunos58" -a "$arch" = "sparc" ] && triplet="${arch}-${vendor}-solaris2.8"
# Use i686 instructions
[ "$_os" = "sunos58" -a "$arch" = "i386" ] && triplet="pentiumpro-${vendor}-solaris2.8"
configure_args="--host=$triplet --build=$triplet $configure_args" # --enable-cxx

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

    compat gmp 5.0.4 1 1
    compat gmp 5.0.5 1 2
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
