#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=libiconv
version=1.15
pkgver=1
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--enable-extra-encodings)
gnu_link iconv

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

reg install
install()
{
    generic_install DESTDIR
    doc NOTES ChangeLog DESIGN NEWS COPYING AUTHORS README COPYING.LIB
    ${__rm} -f ${stagedir}${prefix}/share/doc/*.html

    # Sadly configure ignores --program-prefix, so we have to fix this manually
    ${__mv} ${stagedir}${prefix}/${_bindir}/iconv ${stagedir}${prefix}/${_bindir}/${gnu_prefix}iconv
    ${__mv} ${stagedir}${prefix}/${_mandir}/man1/iconv.1 ${stagedir}/${prefix}/${_mandir}/man1/giconv.1

    # Compatible with previous package
    compat libiconv 1.14 1 2
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
