#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gmp
real_version=6.1.2
version=${real_version}
pkgver=1
source[0]=http://ftp.download-by.net/gnu/gnu/gmp/$topdir-$version.tar.xz
# If there are no patches, simply comment this
patch[0]=gmp-5.1.2-no-c99-trunc.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Get host triplet
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.cpu

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
export LD_OPTIONS="-R$prefix/lib"
configure_args=(--host=$gmp_host --build=$gmp_host "${configure_args[@]}" --enable-cxx)
topsrcdir=${topdir}-${real_version}

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
    doc AUTHORS COPYING COPYING.LESSERv3 NEWS README

    compat gmp 5.0.5 1 4
    compat gmp 5.1.2 1 1
    compat gmp 5.1.3 1 1
    compat gmp 6.0.0a 1 1
    compat gmp 6.1.0 1 1
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
