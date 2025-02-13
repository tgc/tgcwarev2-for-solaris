#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=rsync
version=3.4.1
pkgver=1
source[0]=https://download.samba.org/pub/rsync/src/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=0001-Move-pathjoin-to-lib.patch
patch[1]=0002-Fix-build-with-no-stdint.h.patch
patch[2]=0003-Ensure-SIZE_MAX-is-defined.patch
patch[3]=0004-Missing-include-for-my_strdup.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--with-included-popt --disable-xxhash --disable-zstd --disable-lz4)

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
    doc NEWS.md README.md COPYING
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
