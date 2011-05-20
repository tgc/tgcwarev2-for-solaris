#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=openssl
version=1.0.0d
pkgver=3
source[0]=http://openssl.org/source/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
abbrev_ver=$(echo $version|${__sed} -e 's/\.//g')
baseversion=$(echo $version|${__sed} -e 's/[a-zA-Z]//g')
make_check_target="test"
__configure="./Configure"
shared_args="--prefix=$prefix --openssldir=${prefix}/${_sharedir}/ssl zlib shared"
if [ "$arch" = "sparc" ]; then
    # For Solaris > 7 we default to sparcv8 ISA
    configure_args="solaris-sparcv8-gcc $shared_args"
    # Solaris < 8 supports sparcv7 hardware
    [ "$_os" = "sunos56" -o "$_os" = "sunos57" ] && configure_args="$shared_args solaris-sparcv7-gcc"
else
    configure_args="$shared_args 386 solaris-x86-gcc" 
fi
ignore_deps="LWperl"

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
	# openssl defaults to --march=pentium which should be changed to --march=i386 --mtune=i686
	${__sed} -e 's/-march=pentium/-march=i386 -mtune=i686/' Configure > Configure.myflags
	${__mv} Configure.myflags Configure
	chmod 755 Configure
    fi

    echo $__configure $configure_args
    $__configure $configure_args

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

    # grab 0.9.8g libraries for compat
    setdir $prefix/${_libdir}
    ${__tar} -cf - libcrypto.so.0.9.8 libssl.so.0.9.8 | (cd ${stagedir}${prefix}/${_libdir}; ${__tar} -xf -)
    compat ossl 0.9.8g 1 2
    compat ossl 1.0.0 1 1
    compat ossl 1.0.0a 1 2
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
