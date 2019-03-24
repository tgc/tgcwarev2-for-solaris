#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=bash
real_version=4.4
version=4.4.23
pkgver=1
source[0]=http://mirrors.kernel.org/gnu/bash/$topdir-$real_version.tar.gz

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

patch[0]=bash-4.4-no-loadable-builtins.patch
patch[1]=bash44-001
patch[2]=bash44-002
patch[3]=bash44-003
patch[4]=bash44-004
patch[5]=bash44-005
patch[6]=bash44-006
patch[7]=bash44-007
patch[8]=bash44-008
patch[9]=bash44-009
patch[10]=bash44-010
patch[11]=bash44-011
patch[12]=bash44-012
patch[13]=bash44-013
patch[14]=bash44-014
patch[15]=bash44-015
patch[16]=bash44-016
patch[17]=bash44-017
patch[18]=bash44-018
patch[19]=bash44-019
patch[20]=bash44-020
patch[21]=bash44-021
patch[22]=bash44-022
patch[23]=bash44-023

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
patch_prefix="-p0"
topsrcdir=${topdir}-${real_version}

reg prep
prep()
{
    generic_prep
    setdir source
    ${__rm} -f y.tab.*
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
    ${__mv} ${stagedir}${prefix}/${_docdir}/bash ${stagedir}${prefix}/${_vdocdir}
    doc AUTHORS CHANGES COMPAT NEWS POSIX RBASH README COPYING
    compat bash 3.2.39 1 1
    compat bash 4.2.42 1 1
    compat bash 4.2.45 1 1
    compat bash 4.3.25 1 1
    compat bash 4.3.26 1 1
    compat bash 4.3.27 1 1
    compat bash 4.3.30 1 1
    compat bash 4.3.33 1 1
    compat bash 4.3.39 1 1
    compat bash 4.3.42 1 1
    compat bash 4.4.12 1 1
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
