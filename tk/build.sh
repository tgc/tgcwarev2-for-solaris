#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=tk
version=8.4.19
pkgver=1
source[0]=${topdir}${version}-src.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"     
configure_args="--prefix=$prefix --mandir=$prefix/$_mandir --disable-symbols --enable-man-symlinks --with-tcl=${prefix}/${_libdir}"
topsrcdir=$topdir$version

majorver="${version%.*}"

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    generic_build unix
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    generic_install DESTDIR unix
    doc license.terms changes README
    setdir ${stagedir}${prefix}/${_bindir}
    ${__ln_s} wish${majorver} wish
    setdir ${stagedir}${prefix}/${_libdir}
    ${__ln_s} libtk${majorver}.so libtk.so

    # Grab headers
    ${__mkdir} -p ${stagedir}${prefix}/${_includedir}/tk-private/{generic,unix}
    setdir ${srcdir}/${topsrcdir}
    ${__find} generic unix -name "*.h" -print | ${__tar} -T - -cf - | (cd ${stagedir}${prefix}/${_includedir}/tk-private; ${__tar} -xvBpf -)
    ( cd ${stagedir}${prefix}/${_includedir}
        for i in *.h ; do
            [ -f ${stagedir}${prefix}/${_includedir}/tk-private/generic/$i ] && ${__ln_s} -f ../../$i ${stagedir}${prefix}/${_includedir}/tk-private/generic ;
        done
    )

    # Cleanup references to the build
    ${__gsed} -i "s|${srcdir}/${topsrcdir}/unix|${prefix}/${_libdir}|" ${stagedir}${prefix}/${_libdir}/tkConfig.sh
    ${__gsed} -i "s|${srcdir}/${topsrcdir}|${prefix}/${_includedir}/tk-private|" ${stagedir}${prefix}/${_libdir}/tkConfig.sh
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
