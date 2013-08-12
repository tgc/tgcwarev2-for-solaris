#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=zlib
version=1.2.7
pkgver=1
source[0]=http://zlib.net/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
configure_args=(--shared --prefix=$prefix)
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
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/libz.a
    doc README
    docs_for zlib-devel ChangeLog doc examples test/minigzip.c test/example.c FAQ
    compat zlib 1.2.5 1 1
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
