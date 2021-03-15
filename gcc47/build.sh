#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=gcc
version=4.7.4
pkgver=2
source[0]=http://mirrors.kernel.org/gnu/gcc/$topdir-$version/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=0001-Disable-local-dynamic-TLS-model-on-Solaris-x86-if-as.patch
patch[1]=0002-Add-sse-os-support-check-to-SSSE3-and-SSSE4-tests.patch
patch[2]=0003-gcc-config-sol2-Link-with-thread-libraries-also-for-.patch

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

    # Compatibility information
    for lib in $(${__gsed} -n '/^\[lib/ s/^\[lib\([^]]*\)\]$/\1/p' $metadir/$pkgdef_file | sort -u)
    do
	gccvers="$(gcc_compat lib$lib)"
	if [ -z "$gccvers" ]; then
	    echo "FATAL: Did not find compat information for lib$lib"
	    exit 1
	fi
	for gccver in $gccvers
	do
	    compat lib$lib $gccver 1 9
	done
    done
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
