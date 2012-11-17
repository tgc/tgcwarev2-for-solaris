#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=3.4.6
pkgver=5
source[0]=$topdir-$version.tar.bz2
## If there are no patches, simply comment this
patch[0]=gcc-3.4.6-new-makeinfo.patch
patch[1]=gcc-3.4.6-new-gas.patch
patch[2]=gcc-3.4.6-gnat-share-make.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Common settings for gcc
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.common

# Global settings
configure_args="$global_config_args $linker $assembler $lang_java $gcc_cpu"

# This compiler is bootstrapped with gcc 3.3.6
export PATH=/usr/tgcware/gcc33/bin:$PATH

reg prep
prep()
{
    generic_prep
    setdir source
    ${__gsed} -i "s/@@GCCVERSION@@/$version/" gcc/ada/Makefile.in gcc/ada/bld.adb
}

reg build
build()
{
    setdir source
    # Set bugurl and vendor version
    ${__gsed} -i "/GCCBUGURL/s|URL:[^>]*|URL:$gccbugurl|" gcc/system.h
    ${__gsed} -i "s/$version/$version (release)/" gcc/version.c
    ${__gsed} -i "s/(release)/($gccpkgversion)/" gcc/version.c
    # not gccpkgversion, because the version string will exceed max length
    ${__gsed} -i "s/(release)/(${version}-${pkgver})/" gcc/ada/gnatvsn.ads
    #
    ${__mkdir} -p ../$objdir
    echo "$__configure $configure_args"
    generic_build ../$objdir
    # Build gnat
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

    # Move gcj includes
    ${__mv} $stagedir$lprefix/include/j*.h $stagedir$lprefix/lib/$libsubdir/${arch}-${vendor}-solaris*/$version/include
    ${__mv} $stagedir$lprefix/include/{gnu,java,javax} $stagedir$lprefix/lib/$libsubdir/${arch}-${vendor}-solaris*/$version/include
    ${__mkdir} -p $stagedir$lprefix/lib/$libsubdir/${arch}-${vendor}-solaris*/$version/include/gcj
    ${__mv} $stagedir$lprefix/include/gcj/* $stagedir$lprefix/lib/$libsubdir/${arch}-${vendor}-solaris*/$version/include/gcj
    ${__rmdir} $stagedir$lprefix/include/gcj

    # Move libffi includes
    ${__mv} $stagedir$lprefix/include/ffi.h $stagedir$lprefix/lib/$libsubdir/${arch}-${vendor}-solaris*/$version/include

    # Rearrange libraries for the default arch
    redo_libs
    # Rearrange libraries for the alternate arch (if any)
    [ -n "$altarch" ] && redo_libs $altarch

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
    for i in gcj gcjh
    do
	[ -r ${arch}-${vendor}-solaris${gnu_os_ver}-$i ] && ${__rm} -f ${arch}-${vendor}-solaris${gnu_os_ver}-$i && ${__ln} -sf $i ${arch}-${vendor}-solaris${gnu_os_ver}-$i
    done

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* BUGS FAQ MAINTAINERS NEWS
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
