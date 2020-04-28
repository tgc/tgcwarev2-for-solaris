#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=openssl
version=1.1.1g
pkgver=2
source[0]=https://openssl.org/source/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=openssl-1.1.1d-no-af_inet6.patch
patch[1]=openssl-1.1.1d-fix-no-gai-fallback.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# For cpu settings
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.cpu

# Global settings
abbrev_ver=$(echo $version|${__sed} -e 's/\.//g')
baseversion=$(echo $version|${__sed} -e 's/[a-zA-Z]//g')
make_check_target="test"
__configure="./Configure"
configure_args=(--prefix=$prefix --openssldir=${prefix}/${_sharedir}/ssl zlib shared)
if [ "$arch" = "sparc" ]; then
    configure_args+=(solaris-sparc${gcc_arch}-gcc)
else
    # SSE2 requires Solaris 9 4/04 or later
    configure_args+=(solaris-x86-gcc no-sse2)
    configure_args+=(CFLAGS="-march=${gcc_arch}")
fi
configure_args+=(LDFLAGS="-L$prefix/lib -R$prefix/lib")

reg prep
prep()
{
    generic_prep

    setdir source
    # We need clock_gettime from the posix4 library
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
    setdir ${stagedir}${prefix}/${_mandir}
    for j in $(${__ls} -1d man?)
    do
	cd $j
	for manpage in *
	do
	    if [ -L "${manpage}" ]; then
                TARGET=$(${__ls} -l "${manpage}" | ${__awk} '{ print $NF }')
                ${__ln} -snf "${TARGET}"ssl "${manpage}"ssl
                ${__rm} -f "${manpage}"
	    else
		${__mv} "$manpage" "$manpage""ssl"
	    fi
	done
	cd ..
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
