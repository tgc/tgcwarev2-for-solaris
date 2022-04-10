#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=openssl
version=1.1.1n
pkgver=6
source[0]=https://openssl.org/source/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# For cpu settings
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.cpu

# Global settings
sover=1.1
shortver=11
pname=openssl${shortver}
make_check_target="test"
__configure="./Configure"
configure_args=(--prefix=$prefix --openssldir=${prefix}/${_sharedir}/ssl${shortver} --with-rand-seed=devrandom,egd zlib shared)
if [ "$arch" = "sparc" ]; then
    configure_args+=(solaris-sparc${gcc_arch}-gcc)
else
    # SSE2 requires Solaris 9 4/04 or later
    configure_args+=(solaris-x86-gcc no-sse2)
    configure_args+=(CFLAGS="-march=${gcc_arch}")
fi
configure_args+=(LDFLAGS="-L$prefix/lib -R$prefix/lib -L$prefix/lib/$pname")

reg prep
prep()
{
    generic_prep

    setdir source
    # We need clock_gettime from the rt library
    ${__gsed} -i '/add("-lsocket -lnsl -ldl"),/ s/-ldl/-ldl -lrt/' Configurations/10-main.conf
}

reg build
build()
{
    setdir source

    echo $__configure "${configure_args[@]}"
    $__configure "${configure_args[@]}"

    ${__make} depend
    ${__make}
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
    ${__make} DESTDIR=$stagedir install
    # Relocate
    mkdir -p ${stagedir}${prefix}/{${_includedir},${_libdir}}/$pname
    ${__mv} ${stagedir}${prefix}/${_includedir}/{openssl,$pname/openssl}
    ${__mv} ${stagedir}${prefix}/${_bindir}/{openssl,$pname}
    ${__mv} ${stagedir}${prefix}/${_sharedir}/doc/{openssl,$pname}
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
    chmod 755 ${stagedir}${prefix}/${_libdir}/engines-1.1/*.so
    # Nuke static libraries - they just take up space
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/*.a

    doc README CHANGES LICENSE NEWS

    custom_install=1
    generic_install INSTALL_PREFIX

    # Compatible with previous releases
    compat openssl 1.1.1e 1 1
    compat openssl 1.1.1g 1 2
    compat openssl 1.1.1h 1 3
    compat openssl 1.1.1k 1 4
    compat openssl 1.1.1l 1 5
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
