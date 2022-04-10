#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=openssl
version=1.0.2u
pkgver=8
source[0]=https://openssl.org/source/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=openssl-1.0.2u-cve-2020-1971.patch
patch[1]=openssl-1.0.2u-cve-2021-23840.patch
patch[2]=openssl-1.0.2u-cve-2021-23841.patch
patch[3]=openssl-1.0.2u-cve-2021-3712.patch
patch[4]=openssl-1.0.2u-cve-2022-0778.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# For cpu settings
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.cpu

# Global settings
sover=1.0.0
shortver=102
pname=openssl${shortver}
make_check_target="test"
__configure="./Configure"
configure_args=(--prefix=$prefix --openssldir=${prefix}/${_sharedir}/ssl${shortver} zlib shared)
if [ "$arch" = "sparc" ]; then
    configure_args+=(solaris-sparc${gcc_arch}-gcc)
else
    # SSE2 requires Solaris 9 4/04 or later
    configure_args+=(solaris-x86-gcc no-sse2)
fi

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
    setdir source

    echo $__configure "${configure_args[@]}"
    $__configure "${configure_args[@]}"

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
    ${__make} INSTALL_PREFIX=$stagedir MANDIR=${prefix}/${_mandir} install
    # Relocate
    mkdir -p ${stagedir}${prefix}/{${_includedir},${_libdir}}/$pname
    ${__mv} ${stagedir}${prefix}/${_includedir}/{openssl,$pname/openssl}
    ${__mv} ${stagedir}${prefix}/${_bindir}/{openssl,$pname}
    ${__rm} -rf ${stagedir}${prefix}/{${_sharedir}/ssl/misc,{${_bindir},${_mandir}/man1}/{CA.pl,c_rehash,*tsget}*}
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/*.so
    ln -s ../libcrypto.so.${sover} ${stagedir}${prefix}/${_libdir}/${pname}/libcrypto.so
    ln -s ../libssl.so.${sover} ${stagedir}${prefix}/${_libdir}/${pname}/libssl.so
    for pc in libcrypto libssl openssl
    do
	${__sed} -e "s@\(Libs: -L\${libdir}\)@\1 -L\${libdir}/$pname@" \
	         -e "s@\(Cflags: -I\${includedir}\)@\1 -I\${includedir}/$pname@" \
		 -e "s@\(Requires.*:.*\)\(libssl\)@\1\2$shortver@g" \
		 -e "s@\(Requires.*:.*\)\(libcrypto\)@\1\2$shortver@g" \
		 ${stagedir}${prefix}/${_libdir}/pkgconfig/${pc}.pc > ${stagedir}${prefix}/${_libdir}/pkgconfig/${pc}${shortver}.pc
	rm -f ${stagedir}${prefix}/${_libdir}/pkgconfig/${pc}.pc
    done
    setdir ${stagedir}${prefix}/${_mandir}
    ${__mv} man1/{openssl.1,${pname}.1}
    for manpage in man*/*
    do
	[ "${manpage}" = "man1/${pname}.1" ] && continue
	if [ -L "${manpage}" ]; then
	    TARGET=$(${__ls} -l ${manpage} | ${__awk} '{ print $NF }')
	    ${__ln} -snf ${TARGET}ssl${shortver} ${manpage}ssl${shortver}
	    ${__rm} -f ${manpage}
	else
	    ${__mv} $manpage ${manpage}ssl${shortver}
	fi
    done
    # Make .sos writable
    chmod 755 ${stagedir}${prefix}/${_libdir}/*.so.*
    chmod 755 ${stagedir}${prefix}/${_libdir}/engines/*.so
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
    compat openssl 1.0.2u 1 6
    compat openssl 1.0.2u 1 7
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
