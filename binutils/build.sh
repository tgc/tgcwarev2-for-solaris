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
topdir=binutils
version=2.18
pkgver=1
source[0]=$topdir-$version.tar.bz2
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args="$configure_args --disable-nls --program-prefix=g"

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
    ${__rm} -f ${stagedir}${prefix}/${_mandir}/man1/{dlltool,nlmconv,windres,windmc}*
    # Rename gc++filt
    ${__mv} ${stagedir}${prefix}/${_bindir}/gc++filt ${stagedir}${prefix}/${_bindir}/c++filt

    doc COPYING*
    # This copy is very old. Autoconf has a much newer copy.
    ${__rm} -f ${stagedir}${prefix}/${_infodir}/standards.*
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
