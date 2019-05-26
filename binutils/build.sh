#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=binutils
version=2.32
pkgver=1
source[0]=https://ftpmirror.gnu.org/gnu/binutils/$topdir-$version.tar.lz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--disable-werror --program-prefix=g)
# gcc dies with an ICE when building ld on Solaris 7
[ "$gnu_os_ver" = "2.7" ] && configure_args+=(--enable-ld=no)

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
    ${__rm} -f ${stagedir}${prefix}/${_mandir}/man1/g{dlltool,nlmconv,windres,windmc}*
    doc COPYING*
    compat binutils 2.22 1 6
    compat binutils 2.23.1 1 1
    compat binutils 2.25 1 1
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
