#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=libidn2
version=2.0.4
pkgver=1
#source[0]=http://www.mirrorservice.org/sites/alpha.gnu.org/gnu/libidn/$topdir-$version.tar.gz
# Source bootstrapped on Fedora 26 with gnulib modules gettext-gnu
# and printf-posix added
source[0]=libidn2-2.0.4-tgcware.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--disable-static --with-libiconv-prefix=$prefix --with-libintl-prefix=$prefix)
ac_overrides="ac_cv_prog_RONN=/bin/true"

reg prep
prep()
{
    generic_prep
    setdir source
    # Do not build examples
    ${__gsed} -i 's/examples//' Makefile.in
    # No stdint.h on Solaris < 10
    ${__gsed} -i 's/stdint.h/inttypes.h/' lib/idn2.h.in
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
    doc AUTHORS COPYING* NEWS README.md
    compat libidn2 0.11 1 1
    compat libidn2 2.0.2 1 1
    compat libidn2 2.0.3 1 1
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
