#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
real_topdir=openssl
topdir=compat-openssl102
version=1.0.2u
pkgver=6
source[0]=https://openssl.org/source/$real_topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# For cpu settings
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.cpu

# Global settings
topsrcdir=${real_topdir}-${version}
abbrev_ver=$(echo $version|${__sed} -e 's/\.//g')
baseversion=$(echo $version|${__sed} -e 's/[a-zA-Z]//g')
make_check_target="test"
__configure="./Configure"
configure_args=(--prefix=$prefix --openssldir=${prefix}/${_sharedir}/ssl zlib-dynamic shared no-hw)
if [ "$arch" = "sparc" ]; then
    configure_args+=(solaris-sparc${gcc_arch}-gcc)
else
    # SSE2 requires Solaris 9 4/04 or later
    configure_args+=(solaris-x86-gcc no-sse2)
fi

ignore_deps="TGCossl"

# Buildsystem is non-standard so we take the easy way out
export LD_OPTIONS="-R$prefix/lib"

reg prep
prep()
{
    generic_prep

    setdir source
    ${__gsed} -i '/^SHELL/s/sh/ksh/' Makefile.org
    ${__gsed} -i "s;@LIBDIR@;${prefix}/lib;g" Makefile.org

    if [ "$arch" = "i386" ]; then
	# Override the default gcc march
	${__gsed} -i "/solaris-x86-gcc/ s;-march=pentium;-march=$gcc_arch;" Configure
	# With GNU as there is no need to disable inline assembler
	${__gsed} -i "/solaris-x86-gcc/ s; -DOPENSSL_NO_INLINE_ASM;;" Configure
    fi
    # The -mv8 alias is not supported with newer gcc
    ${__gsed} -i 's/mv8/mcpu=v8/g' Configure

    ${__gsed} -i "/^CFLAG=/s;CFLAG=;CFLAG=-I${prefix}/include;" Makefile
    ${__gsed} -i "/EX_LIBS/s;-lz;-L${prefix}/lib -R${prefix}/lib -lz;" Makefile
}

reg build
build()
{
    echo $__configure "${configure_args[@]}"
    $__configure "${configure_args[@]}"

    setdir source

    ${__make} SHARED_LDFLAGS="-shared -R${prefix}/${_libdir}" depend
    ${__make} SHARED_LDFLAGS="-shared -R${prefix}/${_libdir}"
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    clean stage
    setdir source
    ${__make} INSTALL_PREFIX=$stagedir MANDIR=${prefix}/${_mandir} install_sw
    ${__rm} -rf ${stagedir}${prefix}/${_mandir}
    ${__rm} -rf ${stagedir}${prefix}/${_includedir}
    ${__rm} -rf ${stagedir}${prefix}/${_bindir}
    ${__rm} -rf ${stagedir}${prefix}/${_libdir}/pkgconfig
    ${__rm} -rf ${stagedir}${prefix}/${_sharedir}/ssl
    ${__rm} -rf ${stagedir}${prefix}/${_libdir}/engines
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/*.so

    # Make .sos writable
    chmod 755 ${stagedir}${prefix}/${_libdir}/*.so.*
    # Nuke static libraries - they just take up space
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/*.a

    doc README CHANGES FAQ INSTALL LICENSE NEWS

    custom_install=1
    generic_install INSTALL_PREFIX

    # Compatible with previous releases
    compat openssl 1.0.2j 1 1
    compat openssl 1.0.2k 1 2
    compat openssl 1.0.2o 1 3
    compat openssl 1.0.2p 1 4
    compat openssl 1.0.2r 1 5
}

reg pack
pack()
{
    generic_pack
}

reg distclean
distclean()
{
    clean distclean
}

###################################################
# No need to look below here
###################################################
build_sh $*
