#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=nghttp2
version=1.55.1
pkgver=1
source[0]=https://github.com/${topdir}/${topdir}/releases/download/v${version}/${topdir}-${version}.tar.xz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--disable-static --enable-lib-only)
if [ "$arch" = "i386" -a "$gnu_os_ver" = "2.7" ]; then
  # Building with gcc 3.4.6 avoids this linker error:
  # "ld: fatal: relocations remain against allocatable but non-writable sections"
  export CC="/usr/tgcware/gcc34/bin/gcc"
fi
make_build_target="V=1"
# No python deps from packaged scripts
ignore_deps="TGCpy27"

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
    doc AUTHORS COPYING*
    ${__mv} ${stagedir}${prefix}/${_docdir}/${topdir}/README.rst ${stagedir}${prefix}/${_vdocdir}
    ${__rmdir} ${stagedir}${prefix}/${_docdir}/${topdir}
    ${__rmdir} ${stagedir}${prefix}/${_bindir}
    # manpages for tools that are not packaged
    ${__rm} -rf  ${stagedir}${prefix}/${_mandir}

    compat nghttp2 1.37.0 1 1
    compat nghttp2 1.38.0 1 1
    compat nghttp2 1.40.0 1 1
    compat nghttp2 1.41.0 1 1
    compat nghttp2 1.45.1 1 1
    compat nghttp2 1.47.0 1 1
    compat nghttp2 1.51.0 1 1
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
