#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=bash
real_version=4.3
version=4.3.39
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/bash/$topdir-$real_version.tar.gz

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

patch[0]=""   # no sparse array support in buildpkg
patch[1]=bash43-001
patch[2]=bash43-002
patch[3]=bash43-003
patch[4]=bash43-004
patch[5]=bash43-005
patch[6]=bash43-006
patch[7]=bash43-007
patch[8]=bash43-008
patch[9]=bash43-009
patch[10]=bash43-010
patch[11]=bash43-011
patch[12]=bash43-012
patch[13]=bash43-013
patch[14]=bash43-014
patch[15]=bash43-015
patch[16]=bash43-016
patch[17]=bash43-017
patch[18]=bash43-018
patch[19]=bash43-019
patch[20]=bash43-020
patch[21]=bash43-021
patch[22]=bash43-022
patch[23]=bash43-023
patch[24]=bash43-024
patch[25]=bash43-025
patch[26]=bash43-026
patch[27]=bash43-027
patch[28]=bash43-028
patch[29]=bash43-029
patch[30]=bash43-030
patch[31]=bash43-031
patch[32]=bash43-032
patch[33]=bash43-033
patch[34]=bash43-034
patch[35]=bash43-035
patch[36]=bash43-036
patch[37]=bash43-037
patch[38]=bash43-038
patch[39]=bash43-039

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
