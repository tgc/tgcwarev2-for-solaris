#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=nghttp2
version=1.37.0
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
make_build_target="V=1"
# No python deps from packaged scripts
ignore_deps="TGCpy27"

reg prep
prep()
{
    generic_prep
    if [ "$arch" = "i386" ]; then
      # Replacing Wl,-z text with -mimpure-text is a workaround to avoid
      # "ld: fatal: relocations remain against allocatable but non-writable sections"
      # when linking libnghttp2
      setdir source
      sed -i 's|\$wl-z \${wl}text|-mimpure-text|g' configure
    fi
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
