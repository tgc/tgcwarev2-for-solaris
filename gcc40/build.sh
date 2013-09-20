#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=4.0.4
pkgver=2
source[0]=$topdir-$version.tar.bz2
## If there are no patches, simply comment this
patch[0]=gcc-4.0.4-new-makeinfo.patch
patch[1]=gcc-4.0.4-new-gas.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Common settings for gcc
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.common

# Global settings

# This compiler is bootstrapped with gcc 3.4.6
export PATH=/usr/tgcware/gcc34/bin:$PATH

reg prep
prep()
{
    generic_prep
    setdir source
    # Set bugurl and vendor version
    ${__gsed} -i "s|URL:[^>]*|URL:$gccbugurl|" gcc/version.c
    ${__gsed} -i "s/$version/$version (release)/" gcc/version.c
    ${__gsed} -i "s/(release)/($gccpkgversion)/" gcc/version.c
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
    ${__find} ${stagedir} -type d -name 'libffi' -print | ${__xargs} ${__rmdir}

    # Rearrange libraries
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
    doc COPYING* BUGS FAQ MAINTAINERS NEWS
}

reg check
check()
{
    setdir source
    setdir ../$objdir
    if [ $multilib -eq 0 ]; then
	${__make} -k check
    else
	${__make} -k RUNTESTFLAGS="--target_board='unix{,$multilib_opts}'" check
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
