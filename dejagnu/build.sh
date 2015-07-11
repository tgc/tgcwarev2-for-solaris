#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=dejagnu
version=1.5.3
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/dejagnu/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"

reg prep
prep()
{
    generic_prep
    # runtest needs to use ksh since it relies on "if !"
    setdir source
    ${__gsed} -i 's;#!/bin/sh;#!/bin/ksh;' runtest
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
    doc COPYING NEWS AUTHORS MAINTAINERS TODO
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
