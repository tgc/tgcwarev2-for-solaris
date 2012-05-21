#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=patch
version=2.6.1
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/patch/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=patch-2.6.1-missing-strnlen_c.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
ac_overrides="ac_cv_path_ed_PROGRAM=/usr/bin/ed"

reg prep
prep()
{
    generic_prep
    # testsuite expects gnutools
    setdir source
    ${__gsed} -i 's/cat/gcat/g' tests/*
    ${__gsed} -i 's/touch/gtouch/g' tests/*
    ${__gsed} -i 's/seq/gseq/g' tests/*
    ${__gsed} -i 's/mktemp/gmktemp/g' tests/*
    ${__gsed} -i 's/date/gdate/g' tests/*
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
    doc README NEWS ChangeLog COPYING
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
