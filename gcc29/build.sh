#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=2.95.3
pkgver=2
source[0]=ftp://ftp.sunet.se/pub/gnu/gcc/releases/$topdir-$version/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=gcc-2.95.3-fixinc.patch
patch[1]=gcc-2.95.3-fixinc-disable-rule20.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Common settings for gcc
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.common

# Global settings

# This compiler is bootstrapped using the old gnat distributions which also
# contain gcc 2.8.1.
# sparc: gnat-3.15p-sparc-sun-solaris2.5.1-bin.tar.gz
# x86: gnat-3.12p-i386-pc-solaris2.6-bin.tar.gz
# Put gnat compiler first in the path
export PATH=$HOME/gnat/bin:$PATH

reg prep
prep()
{
    generic_prep
    setdir source
    # Set bugurl and vendor version
    ${__gsed} -i "/GCCBUGURL/s|URL:[^>]*|URL:$gccbugurl|" gcc/system.h
    ${__gsed} -i "s/(release)/($gccpkgversion)/" gcc/version.c gcc/f/version.c
}

reg build
build()
{
    ${__mkdir} -p ${srcdir}/$objdir
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
    ${__make} prefix=$stagedir${lprefix} gxx_include_dir=$stagedir$lprefix/include/c++/$version bindir=$stagedir${prefix}/bin  mandir=$stagedir${prefix}/man infodir=$stagedir${prefix}/info install
    # Fix perms on libstdc++.so.* so we can strip it
    chmod 755 $stagedir${lprefix}/lib/libstdc++.so.*
    custom_install=1
    generic_install
    ${__find} ${stagedir} -name '*.la' -print | ${__xargs} ${__rm} -f

    # Remove libstdc++.a symlink and replace with the actual archive
    ${__rm} -f $stagedir${lprefix}/lib/$libsubdir/${arch}-${vendor}-solaris${gnu_os_ver}/$version/libstdc++.a
    ${__mv} $stagedir${lprefix}/lib/libstdc++.a.2.10.0 $stagedir${lprefix}/lib/$libsubdir/${arch}-${vendor}-solaris${gnu_os_ver}/$version/libstdc++.a

    # Move _G_config.h to c++ include dir
    ${__mv} $stagedir${lprefix}/${arch}-${vendor}-solaris$gnu_os_ver/include/_G_config.h $stagedir${lprefix}/include/c++/$version

    # Remove $lprefix/<target-triplet> which now only holds a duplicate of assert.h
    ${__rm} -rf $stagedir${lprefix}/${arch}-${vendor}-solaris*

    # Rearrange libraries for the default arch
    redo_libs

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
    doc COPYING* gcc/BUGS FAQ MAINTAINERS gcc/NEWS
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
