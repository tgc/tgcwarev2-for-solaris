#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=readline
version=6.3
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/readline/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=readline63-001
patch[1]=readline63-002
patch[2]=readline63-003
patch[3]=readline63-004
patch[4]=readline63-005
patch[5]=readline63-006
patch[6]=readline63-007
patch[7]=readline63-008

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--disable-static)
patch_prefix=-p0

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
    ${__rm} -f ${stagedir}${prefix}/${_docdir}/readline/*
    ${__rmdir} ${stagedir}${prefix}/${_docdir}/readline
    ${__rmdir} ${stagedir}${prefix}/${_bindir}
    doc NEWS CHANGES COPYING
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
