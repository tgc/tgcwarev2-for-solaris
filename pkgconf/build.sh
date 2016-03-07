#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=pkgconf
version=0.9.12-56-g7e6fa32
pkgver=1
# Source fetched from https://github.com/pkgconf/pkgconf
# git archive --format=tar --prefix=pkgconf-0.9.12-56-g7e6fa32/ \
# -o ../pkgconf-0.9.12-56-g7e6fa32.tar pkgconf-0.9.12-56-g7e6fa32
source[0]=$topdir-$version.tar.xz
# If there are no patches, simply comment this
patch[0]=pkgconf-stdint_h.patch
patch[1]=pkgconf-dist-doc.patch
patch[2]=pkgconf-include-order.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
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
