#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=expect
version=5.45
pkgver=1
source[0]=http://prdownloads.sourceforge.net/expect/$topdir$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"

configure_args="--prefix=$prefix --mandir=$prefix/$_mandir --with-tcl=${prefix}/${_libdir} --with-tclinclude=${prefix}/${_includedir} --enable-shared"
make_check_target=test
topsrcdir=$topdir${version}
majorver=$version

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
    setdir ${stagedir}${prefix}/${_libdir}
    ${__ln} -s libexpect${majorver}.so libexpect.so
    ${__rm} -f ${_libdir}/expect-${majorver}/*.a
    doc FAQ README HISTORY
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
