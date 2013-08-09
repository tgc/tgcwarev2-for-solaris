#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=Error
version=0.17019
pkgver=1
source[0]=http://search.cpan.org/CPAN/authors/id/S/SH/SHLOMIF/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
maketest=1
perlpkgname="$(echo $pkgdir | ${__tr} '-' '_')"
__configure="perl"
configure_args=(Makefile.PL)

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    generic_build_perl
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    generic_install_perl
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
