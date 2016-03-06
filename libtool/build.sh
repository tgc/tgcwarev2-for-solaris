#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=libtool
version=2.4.6
pkgver=1
source[0]=ftp://ftp.heanet.ie/pub/gnu/$topdir/$topdir-$version.tar.xz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

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
    # Force an RPATH. Half the testsuite fails otherwise because the binaries
    # it builds cannot find libgcc_s.so.1
    export LD_OPTIONS="-R$prefix/lib"
    generic_check
}

reg install
install()
{
    generic_install DESTDIR
    doc AUTHORS COPYING
    # Re-arrange docs for ltdl
    ${__mkdir} -p ${stagedir}${prefix}/$_docdir/libtool-ltdl-$version
    ${__cp} -p ${stagedir}${prefix}/$_sharedir/libtool/{README,COPYING.LIB} \
      ${stagedir}${prefix}/$_docdir/libtool-ltdl-$version
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
