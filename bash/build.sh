#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=bash
real_version=4.3
version=4.3.27
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/bash/$topdir-$real_version.tar.gz

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Patches have been run through:
# sed 's|../bash-4\.3/||'
# Otherwise they cannot be applied by GNU Patch 2.7.1
patch[0]=bash43-001.edited
patch[1]=bash43-002.edited
patch[2]=bash43-003.edited
patch[3]=bash43-004.edited
patch[4]=bash43-005.edited
patch[5]=bash43-006.edited
patch[6]=bash43-007.edited
patch[7]=bash43-008.edited
patch[8]=bash43-009.edited
patch[9]=bash43-010.edited
patch[10]=bash43-011.edited
patch[11]=bash43-012.edited
patch[12]=bash43-013.edited
patch[13]=bash43-014.edited
patch[14]=bash43-015.edited
patch[15]=bash43-016.edited
patch[16]=bash43-017.edited
patch[17]=bash43-018.edited
patch[18]=bash43-019.edited
patch[19]=bash43-020.edited
patch[20]=bash43-021.edited
patch[21]=bash43-022.edited
patch[22]=bash43-023.edited
patch[23]=bash43-024.edited
patch[24]=bash43-025.edited
patch[25]=bash43-026.edited
patch[26]=bash43-027.edited
patch[27]=bash-4.2-cve-2014-7169-2.patch

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
    ${__mv} ${stagedir}${prefix}/${_docdir}/bash ${stagedir}${prefix}/${_vdocdir}
    doc AUTHORS CHANGES COMPAT NEWS POSIX RBASH README COPYING
    compat bash 3.2.39 1 1
    compat bash 4.2.42 1 1
    compat bash 4.2.45 1 1
    compat bash 4.3.25 1 1
    compat bash 4.3.26 1 1
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
