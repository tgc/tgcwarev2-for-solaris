#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=smartmontools
version=6.4
pkgver=1
source[0]=http://downloads.sourceforge.net/$topdir/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=smartmontools-6.4-cxx-fix.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
ac_overrides="ac_cv_func_regcomp=no"
configure_args+=(--docdir=$prefix/$_vdocdir --with-initscriptdir=$prefix/$_vdocdir --with-working-snprintf=no)

reg prep
prep()
{
    generic_prep
    setdir source
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
    ${__mv} ${stagedir}${prefix}/${_vdocdir}/smartd ${stagedir}${prefix}/${_vdocdir}/smartd.init
    ${__rm} -f ${stagedir}${prefix}/${_sysconfdir}/smartd.conf
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
