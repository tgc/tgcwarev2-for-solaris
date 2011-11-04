#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=3.4.6
pkgver=4
source[0]=$topdir-$version.tar.bz2
## If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# GCC package naming guide
# gcc - c
# gcc-c++ - cx
# gcc-gnat - gn
# gcc-objc - ob
# gcc-objc++ - ox
# gcc-java - jv

# Global settings
prefix=/usr/tgcware/$topdir-$version
__configure="../$topsrcdir/configure"
make_build_target=bootstrap

# Define abbreviated version number (for pkgdef)
abbrev_ver=$(echo $version | ${__tr} -d '.')

global_config_args="--prefix=$prefix --with-local-prefix=$prefix --disable-nls --enable-shared"
langs="--enable-languages=c,c++,f77,objc,ada"
configure_args="$global_config_args $langs $platform_configure_args"
objdir=cccgoa_native
export CC=/export/home/tgc/gnat/bin/gcc
export GNATROOT=/export/home/tgc/gnat
export PATH=/export/home/tgc/gnat/bin:$PATH

# Conditionals for pkgdef
[ -n "$(isainfo | grep sparcv9)" ] && v9libs=1
[ "$_os" = "sunos56" ] && sol26=1
[ "$_os" = "sunos57" ] && sol27=1

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
    setdir $srcdir/$objdir
    ${__configure} $configure_args
    ${__make} $make_build_target
    setdir ${srcdir}/${objdir}
    ${__make} -C gcc gnatlib
    ${__make} -C gcc gnattools
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
    lprefix=$topinstalldir
    ${__mkdir} -p ${stagedir}${lprefix}/${_libdir}
    setdir ${stagedir}${prefix}/${_libdir}
    ${__tar} -cf - libgcc_s.so.1 libstdc++.so.6* libg2c.so.0* libobjc.so.1* |
	(cd ${stagedir}${lprefix}/${_libdir}; ${__tar} -xvBpf -)

    if [ "x$v9libs" != "x" ]; then
	${__mkdir} -p ${stagedir}${lprefix}/${_libdir}/sparcv9
	setdir ${stagedir}${prefix}/${_libdir}/sparcv9
	${__tar} -cf - libgcc_s.so.1 libstdc++.so.6* libg2c.so.0* libobjc.so.1* |
	    (cd ${stagedir}${lprefix}/${_libdir}/sparcv9; ${__tar} -xvBpf -)
    fi

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* BUGS FAQ MAINTAINERS NEWS

    for pkg in libg2c0 libgcc_s1 libobjc1 libstdc++6
    do
	${__rm} -f $metadir/compver.$pkg
	compat $pkg 3.4.6 1 $pkgver
    done
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
