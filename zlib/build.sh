#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# build.sh helper functions
. ${BUILDPKG_BASE}/scripts/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=zlib
version=1.2.3
pkgver=3
source[0]=$topdir-$version.tar.bz2
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Global settings
configure_args='--shared --prefix=$prefix'
export LDSHARED="gcc -shared -R ${prefix}/${_libdir} -Wl,-h,libz.so.1"
shortroot=1

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
    setdir source
    ${__make} test
}

reg install
install()
{
    generic_install prefix
    doc README
    docs_for zlib-devel ChangeLog algorithm.txt minigzip.c example.c FAQ
#    ${__mv} ${stagedir}${prefix}/share/${_mandir} ${stagedir}${prefix}
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
