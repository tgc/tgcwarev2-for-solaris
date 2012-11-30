#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=3.0.4
pkgver=2
source[0]=ftp://ftp.sunet.se/pub/gnu/gcc/releases/$topdir-$version/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=gcc-3.0.4-libjava-testsuite-link.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Common settings for gcc
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.common

# Global settings

# This compiler is bootstrapped with gcc 2.95.3
export PATH=/usr/tgcware/gcc29/bin:$PATH

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    setdir source
    # Set bugurl and vendor version
    ${__gsed} -i "/GCCBUGURL/s|URL:[^>]*|URL:$gccbugurl|" gcc/system.h
    ${__gsed} -i "s/$version/$version (release)/" gcc/version.c
    ${__gsed} -i "s/(release)/($gccpkgversion)/" gcc/version.c gcc/f/version.c
    #
    ${__mkdir} -p ../$objdir
    echo "$__configure $configure_args"
    generic_build ../$objdir
}

reg install
install()
{
    clean stage
    setdir ${srcdir}/${objdir}
    mkdir -p $stagedir${prefix}
    mkdir -p $stagedir${lprefix}
    ${__make} -e prefix=$stagedir${lprefix} gxx_include_dir=$stagedir$lprefix/include/c++/$version glibcppinstalldir=$stagedir$lprefix/include/c++/$version bindir=$stagedir${prefix}/bin  mandir=$stagedir${prefix}/man infodir=$stagedir${prefix}/info install
    custom_install=1
    generic_install
    ${__find} ${stagedir} -name '*.la' -print | ${__xargs} ${__rm} -f

    # Move gcj includes
    ${__mv} $stagedir$lprefix/include/{gnu,gcj,java,jni.h,jvmpi.h} $stagedir$lprefix/lib/$libsubdir/${arch}-${vendor}-solaris*/$version/include

    # Move libobjc.so* so redo_libs can fix it up
    ${__mv} $stagedir$lprefix/lib/$libsubdir/${arch}-${vendor}-solaris*/$version/libobjc.so* $stagedir$lprefix/lib

    # Rearrange libraries for the default arch
    redo_libs

    # Remove obsolete gccbug script
    ${__rm} -f $stagedir$prefix/bin/gccbug

    # Turn all the hardlinks in bin into symlinks
    setdir ${stagedir}${prefix}/${_bindir}
    for i in c++ ${arch}-${vendor}-solaris*-c++ ${arch}-${vendor}-solaris*-g++
    do
	[ -r $i ] && ${__rm} -f $i && ${__ln} -sf g++ $i
    done
    for i in ${arch}-${vendor}-solaris*-gcc ${arch}-${vendor}-solaris*-gcc-$version
    do
	[ -r $i ] && ${__rm} -f $i && ${__ln} -sf gcc $i
    done

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* BUGS FAQ MAINTAINERS gcc/NEWS
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
    iprefix=${topdir}${abbrev_majorminor}
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
