#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=ppl
version=0.12.1
pkgver=1
source[0]=http://bugseng.com/products/ppl/download/ftp/releases/$version/$topdir-$version.tar.xz
# If there are no patches, simply comment this
patch[0]=ppl-gmp-5.1.0.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--disable-static --enable-interfaces="cxx c")
PATH=/usr/tgcware/gcc45/bin:$PATH
export PATH

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
    # Rearrange docs
    ${__mv} ${stagedir}${prefix}/${_docdir}/ppl ${stagedir}${prefix}/${_vdocdir}
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
