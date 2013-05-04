#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=4.7.3
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/gcc/releases/$topdir-$version/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Common settings for gcc
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.common

# Global settings
java_libver=13

# This compiler is bootstrapped with gcc 4.6.x
export PATH=/usr/tgcware/gcc46/bin:$PATH

reg prep
prep()
{
    generic_prep
    setdir source
    # Set bugurl and vendor version
    ${__gsed} -i "/BUGURL=.*bugs.html.*/ s|http://gcc.gnu.org/bugs.html|$gccbugurl|" gcc/configure
    ${__gsed} -i "/PKGVERSION=.*GCC.*/ s|GCC|$gccpkgversion|" gcc/configure
}

reg build
build()
{
    setup_tools
    ${__mkdir} -p ${srcdir}/$objdir
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

    # Remove libffi
    ${__find} ${stagedir} -type l -name 'libffi*' -print | ${__xargs} ${__rm} -f
    ${__find} ${stagedir} -type f -name 'libffi*' -print | ${__xargs} ${__rm} -f
    ${__find} ${stagedir} -type f -name 'ffi*.h' -print | ${__xargs} ${__rm} -f
    ${__find} ${stagedir} -type f -name 'ffi*.3' -print | ${__xargs} ${__rm} -f
    # man3 is now empty
    ${__rmdir} ${stagedir}${prefix}/$iprefix/man/man3

    # libquadmath is not available on sparc but documentation is installed
    [ "$arch" = "sparc" ] && ${__rm} -f ${stagedir}${prefix}/$iprefix/info/libquadmath.info

    # Rearrange libraries for the default arch
    redo_libs
    # Rearrange libraries for the alternate arch (if any)
    [ -n "$altarch" ] && redo_libs $altarch

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
    for i in ${arch}-${vendor}-solaris*-gfortran
    do
	[ -r $i ] && ${__rm} -f $i && ${__ln} -sf gfortran $i
    done

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* MAINTAINERS NEWS
}

reg check
check()
{
    setdir source
    setdir ../$objdir
    if [ $m64run -eq 0 ]; then
	${__make} -k check
    else
	${__make} -k RUNTESTFLAGS="--target_board='unix{,-m64}'" check
    fi
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
