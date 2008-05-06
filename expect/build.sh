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
topdir=expect
version=5.43.0
pkgver=1
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=expect-5.43-no-rpath.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"

configure_args="--prefix=$prefix --mandir=$prefix/$_mandir --with-tcl=${prefix}/${_libdir} --with-tclinclude=${prefix}/${_includedir}/tcl-private --with-tkinclude=${prefix}/${_includedir}/tk-private --with-tk=${prefix}/${_libdir} --enable-shared"

topsrcdir=$topdir-${version%.*}
majorver=5.43

reg prep
prep()
{
    generic_prep
    sleep 1
    touch configure
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
    generic_install INSTALL_ROOT
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
