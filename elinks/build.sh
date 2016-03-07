#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=elinks
version=0.13-0.1.4efea7e
pkgver=1
source[0]=http://repo.or.cz/elinks.git/snapshot/4efea7e314b49df660799e71ede713dff0cd1230.tar.gz
# If there are no patches, simply comment this
patch[0]=elinks-inet_aton.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export PKG_CONFIG=pkgconf
export CPPFLAGS="-I$prefix/lib"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"

# No MAP_ANON for Solaris < 8
[ "$gnu_os_ver" = "2.7" ] && ac_overrides="ac_cv_func_mmap_fixed_mapped=no"
topsrcdir=${topdir}-4efea7e
configure_args+=(--without-x --with-lzma)

reg prep
prep()
{
    generic_prep
    setdir source
    bash autogen.sh
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
    doc AUTHORS COPYING README SITES TODO
    ${__rmdir} ${stagedir}${prefix}/$_libdir
    ${__rm} ${stagedir}${prefix}/$_sharedir/locale/locale.alias
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
