#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=bash
real_version=4.2
version=4.2.42
pkgver=1
source[0]=$topdir-$real_version.tar.gz

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

patch[0]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-001
patch[1]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-002
patch[2]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-003
patch[3]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-004
patch[4]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-005
patch[5]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-006
patch[6]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-007
patch[7]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-008
patch[8]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-009
patch[9]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-010
patch[10]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-011
patch[11]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-012
patch[12]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-013
patch[13]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-014
patch[14]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-015
patch[15]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-016
patch[16]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-017
patch[17]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-018
patch[18]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-019
patch[19]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-020
patch[20]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-021
patch[21]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-022
patch[22]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-023
patch[23]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-024
patch[24]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-025
patch[25]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-026
patch[26]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-027
patch[27]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-028
patch[28]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-029
patch[29]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-030
patch[30]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-031
patch[31]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-032
patch[32]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-033
patch[33]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-034
patch[34]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-035
patch[35]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-036
patch[36]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-037
patch[37]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-038
patch[38]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-039
patch[39]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-040
patch[40]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-041
patch[41]=ftp://ftp.sunet.se/pub/gnu/bash/bash-${real_version}-patches/bash42-042

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
patch_prefix="-p0"
topsrcdir=${topdir}-${real_version}

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
    doc AUTHORS CHANGES COMPAT NEWS POSIX RBASH README COPYING
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
