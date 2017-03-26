#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=openssl
version=1.0.2k
pkgver=2
source[0]=http://openssl.org/source/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# For cpu settings
. ${BUILDPKG_BASE}/gcc/build.sh.gcc.cpu

# Global settings
abbrev_ver=$(echo $version|${__sed} -e 's/\.//g')
baseversion=$(echo $version|${__sed} -e 's/[a-zA-Z]//g')
make_check_target="test"
__configure="./Configure"
configure_args=(--prefix=$prefix --openssldir=${prefix}/${_sharedir}/ssl zlib-dynamic shared)
if [ "$arch" = "sparc" ]; then
    configure_args+=(solaris-sparc${gcc_arch}-gcc)
else
    configure_args+=(386 solaris-x86-gcc)
fi

# Buildsystem is non-standard so we take the easy way out
export LD_OPTIONS="-R$prefix/lib"

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    setdir source
    ${__gsed} -i '/^SHELL/s/sh/ksh/' Makefile.org
    ${__gsed} -i "s;@LIBDIR@;${prefix}/lib;g" Makefile.org

    if [ "$arch" = "i386" ]; then
	# openssl defaults to --march=pentium which should be changed
	${__gsed} -i "/solaris-x86-gcc/ s;-march=pentium;-march=$gcc_arch;" Configure
	# There is no reason to disable inline asm
	${__gsed} -i "/solaris-x86-gcc/ s; -DOPENSSL_NO_INLINE_ASM;;" Configure
    fi
    # The -mv8 alias is not supported with newer gcc
    ${__gsed} -i 's/mv8/mcpu=v8/g' Configure

    echo $__configure "${configure_args[@]}"
    $__configure "${configure_args[@]}"

    ${__gsed} -i "/^CFLAG=/s;CFLAG=;CFLAG=-I${prefix}/include;" Makefile
    ${__gsed} -i "/EX_LIBS/s;-lz;-L${prefix}/lib -R${prefix}/lib -lz;" Makefile
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
    chmod 755 ${stagedir}${prefix}/${_libdir}/engines/*.so
    # Nuke static libraries - they just take up space
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/*.a

    doc README CHANGES FAQ INSTALL LICENSE NEWS

    custom_install=1
    generic_install INSTALL_PREFIX

    # Compatible with previous releases
    compat openssl 1.0.2j 1 1
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
