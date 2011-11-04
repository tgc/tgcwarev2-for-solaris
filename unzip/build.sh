#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=unzip
version=5.52
pkgver=3
source[0]=${topdir}552.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
shortroot=1
__configure="make"
make_build_target="CC=gcc -f unix/Makefile solaris"
configure_args="$make_build_target"
no_configure=1

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
    generic_install prefix
    doc README BUGS LICENSE ToDo
    ${__mv} ${stagedir}${prefix}/man ${stagedir}${prefix}/${_mandir}
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
