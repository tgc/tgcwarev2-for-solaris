#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=4.7.3
pkgver=3
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
    ${__rmdir} ${stagedir}${prefix}/man/man3

    # libquadmath is not available on sparc but documentation is installed
    [ "$arch" = "sparc" ] && ${__rm} -f ${stagedir}${prefix}/info/libquadmath.info

    # Rearrange libraries
    redo_libs

    # Turn all the hardlinks in bin into symlinks
    redo_bin

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* MAINTAINERS NEWS
}

reg check
check()
{
    setdir source
    setdir ../$objdir
    if [ $multilib -eq 0 ]; then
	${__make} -k check
    else
	${__make} -k RUNTESTFLAGS="--target_board='unix{,$multilib_testopt}'" check
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
