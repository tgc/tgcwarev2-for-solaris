#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=cmake
version=2.8.12.2
pkgver=1
source[0]=https://cmake.org/files/v2.8/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
LD_OPTIONS="-R/usr/tgcware/lib"
LDFLAGS="-L/usr/tgcware/lib -R/usr/tgcware/lib"
CFLAGS="-I/usr/tgcware/include"
CXXFLAGS="-I/usr/tgcware/include"
CC=gcc
CXX=g++
export LD_OPTIONS LDFLAGS CFLAGS CXXFLAGS CC CXX
configure_args=(--prefix=$prefix --docdir=$_docdir/${topdir}-2.8 --mandir=share)
configure_args+=(--system-curl --system-expat --system-zlib --system-bzip2)
configure_args+=(--parallel=2)
make_check_target=test

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
