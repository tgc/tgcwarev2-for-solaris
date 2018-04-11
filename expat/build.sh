#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=expat
version=2.2.5
pkgver=1
source[0]=http://downloads.sourceforge.net/project/expat/expat/${version}/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export LDFLAGS="-L/usr/tgcware/lib -R/usr/tgcware/lib"
export CPPFLAGS="-I/usr/tgcware/include"

reg prep
prep()
{
    generic_prep
    ${__gsed} -i 's/fgrep -q/fgrep -s/' configure
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
    doc COPYING Changes README.md AUTHORS
    compat expat 2.1.0 1 1
    ${__rm} -rf ${stagedir}${prefix}/share/doc/expat

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
