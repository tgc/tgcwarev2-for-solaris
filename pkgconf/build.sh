#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=pkgconf
version=1.6.0
pkgver=2
source[0]=https://github.com/pkgconf/pkgconf/archive/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=0001-Fix-building-without-stdint.h.patch
patch[1]=0002-Use-u-instead-of-zu-for-compatibility.patch
patch[2]=0003-Install-NEWS-and-COPYING-files.patch
patch[3]=0004-Re-add-sys-stat.h-to-stdinc.h.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
topsrcdir=${topdir}-${topdir}-$version
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--docdir=$prefix/$_vdocdir)

reg prep
prep()
{
    generic_prep
    setdir source
    bash autogen.sh
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
