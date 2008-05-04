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
topdir=bash
real_version=3.2
version=3.2.39
pkgver=1
source[0]=$topdir-$real_version.tar.gz

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

patch[0]=${srcfiles}/${topdir}-${real_version}-patches/bash32-001
patch[1]=${srcfiles}/${topdir}-${real_version}-patches/bash32-002
patch[2]=${srcfiles}/${topdir}-${real_version}-patches/bash32-003
patch[3]=${srcfiles}/${topdir}-${real_version}-patches/bash32-004
patch[4]=${srcfiles}/${topdir}-${real_version}-patches/bash32-005
patch[5]=${srcfiles}/${topdir}-${real_version}-patches/bash32-006
patch[6]=${srcfiles}/${topdir}-${real_version}-patches/bash32-007
patch[7]=${srcfiles}/${topdir}-${real_version}-patches/bash32-008
patch[8]=${srcfiles}/${topdir}-${real_version}-patches/bash32-009
patch[9]=${srcfiles}/${topdir}-${real_version}-patches/bash32-010
patch[10]=${srcfiles}/${topdir}-${real_version}-patches/bash32-011
patch[11]=${srcfiles}/${topdir}-${real_version}-patches/bash32-012
patch[12]=${srcfiles}/${topdir}-${real_version}-patches/bash32-013
patch[13]=${srcfiles}/${topdir}-${real_version}-patches/bash32-014
patch[14]=${srcfiles}/${topdir}-${real_version}-patches/bash32-015
patch[15]=${srcfiles}/${topdir}-${real_version}-patches/bash32-016
patch[16]=${srcfiles}/${topdir}-${real_version}-patches/bash32-017
patch[17]=${srcfiles}/${topdir}-${real_version}-patches/bash32-018
patch[18]=${srcfiles}/${topdir}-${real_version}-patches/bash32-019
patch[19]=${srcfiles}/${topdir}-${real_version}-patches/bash32-020
patch[20]=${srcfiles}/${topdir}-${real_version}-patches/bash32-021
patch[21]=${srcfiles}/${topdir}-${real_version}-patches/bash32-022
patch[22]=${srcfiles}/${topdir}-${real_version}-patches/bash32-023
patch[23]=${srcfiles}/${topdir}-${real_version}-patches/bash32-024
patch[24]=${srcfiles}/${topdir}-${real_version}-patches/bash32-025
patch[25]=${srcfiles}/${topdir}-${real_version}-patches/bash32-026
patch[26]=${srcfiles}/${topdir}-${real_version}-patches/bash32-027
patch[27]=${srcfiles}/${topdir}-${real_version}-patches/bash32-028
patch[28]=${srcfiles}/${topdir}-${real_version}-patches/bash32-029
patch[29]=${srcfiles}/${topdir}-${real_version}-patches/bash32-030
patch[30]=${srcfiles}/${topdir}-${real_version}-patches/bash32-031
patch[31]=${srcfiles}/${topdir}-${real_version}-patches/bash32-032
patch[32]=${srcfiles}/${topdir}-${real_version}-patches/bash32-033
patch[33]=${srcfiles}/${topdir}-${real_version}-patches/bash32-034
patch[34]=${srcfiles}/${topdir}-${real_version}-patches/bash32-035
patch[35]=${srcfiles}/${topdir}-${real_version}-patches/bash32-036
patch[36]=${srcfiles}/${topdir}-${real_version}-patches/bash32-037
patch[37]=${srcfiles}/${topdir}-${real_version}-patches/bash32-038
patch[38]=${srcfiles}/${topdir}-${real_version}-patches/bash32-039

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
