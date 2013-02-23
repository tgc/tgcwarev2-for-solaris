#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=zip
version=3.0
pkgver=1
source[0]=http://prdownloads.sourceforge.net/infozip/${topdir}30.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
LDFLAGS="-L$prefix/lib -R$prefix/lib -lbz2"
CPPFLAGS="-I$prefix/include"
shortroot=1
__configure="make"
make_build_target="-f unix/Makefile generic_gcc"
make_install_target="-f unix/Makefile install"
configure_args="$make_build_target LFLAGS2=\\\"$LDFLAGS\\\" CC=\\\"gcc $CPPFLAGS\\\""
no_configure=1
topsrcdir=${topdir}30

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    setdir source
    ${__make} -e -f unix/Makefile generic_gcc LFLAGS2="$LDFLAGS" CC="gcc $CPPFLAGS"
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
    doc README BUGS LICENSE
    ${__mv} ${stagedir}${prefix}/man ${stagedir}${prefix}/share
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
