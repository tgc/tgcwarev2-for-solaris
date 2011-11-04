#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
snapshot=
topdir=gcc
version=4.0.4
pkgver=1
source[0]=$topdir-$version.tar.bz2
[ -n "$snapshot" ] && source[0]=$topdir-$version-$snapshot.tar.bz2
## If there are no patches, simply comment this
patch[0]=gcc-4.0.4-newer-gas.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
[ -n "$snapshot" ] && topsrcdir=gcc-$version-$snapshot
lprefix=$prefix
prefix=/usr/tgcware/$topdir-$version
__configure="../$topsrcdir/configure"
make_build_target=bootstrap

# Define abbreviated version number (for pkgdef)
abbrev_ver=$(echo $version | ${__tr} -d '.')

# Configure args
global_config_args="--prefix=$prefix --with-local-prefix=$prefix --with-libiconv-prefix=$lprefix --with-gmp=$lprefix --with-mpfr=$lprefix --disable-nls --enable-shared --enable-threads=posix95"
langs="--enable-languages=c,ada,c++,f95,objc"
objdir=all_native
# platform/arch specific options
[ "$_os" = "sunos56" -a "$arch" = "i386" ] && platform_configure_args="--with-gnu-as --with-as=$lprefix/bin/gas"
[ "$_os" = "sunos56" -a "$arch" = "i386" ] && platform_configure_args="$platform_configure_args --with-gnu-ld --with-ld=$lprefix/bin/gld"
[ "$arch" = "sparc" ] && vendor="sun" || vendor="pc"

configure_args="$global_config_args $langs $platform_configure_args"

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    setdir source
    ${__mkdir} -p ../$objdir
    echo "$__configure $configure_args"
    generic_build ../$objdir
}

reg install
install()
{
    clean stage
    setdir ${srcdir}/${objdir}
    ${__make} DESTDIR=$stagedir install
    custom_install=1
    generic_install
    ${__find} ${stagedir} -name '*.la' -print | ${__xargs} ${__rm} -f

    # Prepare for split lib packages
    ${__mkdir} -p ${stagedir}${lprefix}/${_libdir}
    setdir ${stagedir}${prefix}/${_libdir}
    ${__tar} -cf - libgcc_s.so.1 libstdc++.so.6* libgfortran.so.0* libobjc.so.1* |
	(cd ${stagedir}${lprefix}/${_libdir}; ${__tar} -xvBpf -)

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* BUGS FAQ MAINTAINERS NEWS

    # Setup compat files
    for pkg in libgcc_s1 libstdc++6 libobjc1
    do
        ${__rm} -f $metadir/compver.$pkg
        compat $pkg 3.4.6 1 9
        compat $pkg 4.0.4 1 9
    done
    compat libgfortran0 4.0.4 1 9
}

reg check
check()
{
    setdir source
    setdir ../$objdir
    ${__make} -k check
}

reg pack
pack()
{
    iprefix=$topdir-$version
    generic_pack
}

reg distclean
distclean()
{
    META_CLEAN="$META_CLEAN compver.*"
    clean distclean
    ${__rm} -rf $srcdir/$objdir
}

###################################################
# No need to look below here
###################################################
build_sh $*
