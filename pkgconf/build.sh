#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=pkgconf
version=1.4.2
pkgver=1
source[0]=https://github.com/pkgconf/pkgconf/archive/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=pkgconf-1.4.2-no-stdint_h.patch
patch[1]=pkgconf-dist-doc.patch

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
