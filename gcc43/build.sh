#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# build.sh helper functions
. ${BUILDPKG_BASE}/scripts/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
snapshot=
topdir=gcc
version=4.3.3
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/gcc/releases/$topdir-$version/$topdir-$version.tar.bz2
#source[0]=gcc-4.3-$snapshot.tar.bz2
## If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Global settings
lprefix=$prefix
[ -n "$snapshot" ] && topsrcdir=gcc-$version-$snapshot
prefix=/usr/tgcware/$topdir-$version
__configure="../$topsrcdir/configure"
make_build_target=bootstrap

# Define abbreviated version number (for pkgdef)
abbrev_ver=$(echo $version | ${__tr} -d '.')
# Just major.minor, no subminors
majorminor=$(echo $version | cut -d. -f1-2)

global_config_args="--prefix=$prefix --with-local-prefix=$prefix --with-libiconv-prefix=$lprefix --with-gmp=$lprefix --with-mpfr=$lprefix --disable-nls --enable-shared"
langs="--enable-languages=c,ada,c++,fortran,objc,obj-c++"
objdir=all_native
# platform/arch specific options
[ "$_os" = "sunos56" ] && platform_configure_args="--enable-threads=posix95 --enable-obsolete"
[ "$_os" = "sunos56" -a "$arch" = "i386" ] && platform_configure_args="$platform_configure_args --with-gnu-as --with-as=$lprefix/bin/gas"
[ "$arch" = "sparc" ] && vendor="sun" || vendor="pc"

configure_args="$global_config_args $langs $platform_configure_args"

export CONFIG_SHELL=/bin/ksh

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
    ${__tar} -cf - libgcc_s.so.1 libstdc++.so.6* libgfortran.so.3* libobjc.so.2* libgomp.so.1* |
	(cd ${stagedir}${lprefix}/${_libdir}; ${__tar} -xvBpf -)

    # Grab gnat libraries from adalib
    ${__cp} -p ${stagedir}${prefix}/${_libdir}/gcc/${arch}-${vendor}-solaris*/${version}/adalib/libgnarl-$majorminor.so ${stagedir}${lprefix}/${_libdir}
    ${__cp} -p ${stagedir}${prefix}/${_libdir}/gcc/${arch}-${vendor}-solaris*/${version}/adalib/libgnat-$majorminor.so ${stagedir}${lprefix}/${_libdir}

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* MAINTAINERS NEWS

    # Setup compat files
    for pkg in libgcc_s1 libstdc++6
    do
	${__rm} -f $metadir/compver.$pkg
	compat $pkg 3.4.6 1 5
	compat $pkg 4.0.4 1 2
	compat $pkg 4.1.2 1 2
	compat $pkg 4.2.3 1 2
	compat $pkg 4.2.4 1 2
	compat $pkg 4.3.1 1 2
	compat $pkg 4.3.2 1 2
    done
    compat libobjc2 4.2.3 1 2
    compat libobjc2 4.2.4 1 2
    compat libobjc2 4.3.1 1 2
    compat libobjc2 4.3.2 1 2
    compat libgomp1 4.2.3 1 2
    compat libgomp1 4.2.4 1 2
    compat libgomp1 4.3.1 1 2
    compat libgomp1 4.3.2 1 2
    compat libgfortran3 4.3.1 1 2
    compat libgfortran3 4.3.2 1 2
    compat libgnat43 4.3.2 1 2
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
    setdir $srcdir
    ${__rm} -rf $objdir
}

###################################################
# No need to look below here
###################################################
build_sh $*
