#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=xz
version=5.2.12
pkgver=1
source[0]=https://tukaani.org/xz/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I/usr/tgcware/lib"
export LDFLAGS="-L/usr/tgcware/lib -R/usr/tgcware/lib"

ac_overrides="gl_cv_posix_shell=/usr/bin/ksh"

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
    ${__mv} ${stagedir}${prefix}/${_docdir}/xz ${stagedir}${prefix}/${_vdocdir}
    ${__rm} -r ${stagedir}${prefix}/${_mandir}/{de,fr}
    compat xzutils 5.0.4 1 1
    compat xzutils 5.0.5 1 1
    compat xzutils 5.2.1 1 1
    compat xzutils 5.2.4 1 1
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
