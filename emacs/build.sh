#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=emacs
version=24.5
pkgver=1
source[0]=ftp://ftp.heanet.ie/pub/gnu/$topdir/$topdir-$version.tar.xz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
basic_args=("${configure_args[@]}")

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    setdir source
    mkdir -p build-nox && cd build-nox
    ${__ln_s} ../configure .
    configure_args=("${basic_args[@]}" --with-x=no)
    generic_build build-nox
    setdir source
    mkdir -p build-x11 && cd build-x11
    ${__ln_s} ../configure .
    configure_args=("${basic_args[@]}" --with-xpm=no --with-jpeg=no --with-png=no --with-gif=no --with-tiff=no)
    generic_build build-x11
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    generic_install DESTDIR build-x11
    ${__install} -pm 755 $srcdir/$topsrcdir/build-nox/src/emacs ${stagedir}${prefix}/${_bindir}/emacs-${version}-nox
    (cd ${stagedir}${prefix}/${_bindir} && ${__ln_s} emacs-${version}-nox emacs-nox)
    ${__mv} ${stagedir}${prefix}/${_infodir}/{info.info.gz,info.gz}
    ${__mv} ${stagedir}${prefix}/${_bindir}/{ctags,gctags}
    ${__mv} ${stagedir}${prefix}/${_mandir}/man1/{ctags.1.gz,gctags.1.gz}
    ${__rm} -f ${stagedir}${prefix}/var/games/emacs/*scores
    ${__rmdir} ${stagedir}${prefix}/var/games/emacs
    ${__rmdir} ${stagedir}${prefix}/var/games
    ${__rmdir} ${stagedir}${prefix}/var
    ${__gsed} -i 's|/usr/bin/perl|/usr/tgcware/bin/perl|' ${stagedir}${prefix}/${_bindir}/grep-changelog
    custom_install=1
    generic_install
    docs_for emacs-common etc/NEWS COPYING BUGS README
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
