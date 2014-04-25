#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=rsync
version=3.0.9
pkgver=1
source[0]=http://rsync.samba.org/ftp/rsync/src/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--with-included-popt)

reg prep
prep()
{
    generic_prep
    setdir source
    # Fix IPv6 test
    # It should test for something that the header would define instead of relying
    # on the preprocesser to stop when the include fails (gcc < 4.5 does not)
    ${__gsed} -i 's/__sun/_NETINET_IP6_H/g' configure.sh
}

reg build
build()
{
    generic_build
}

reg install
install()
{
    generic_install DESTDIR
    doc NEWS README COPYING
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
