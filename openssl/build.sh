#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# build.sh helper functions
. ${BUILDPKG_BASE}/scripts/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=openssl
version=0.9.7l
pkgver=1
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=openssl-0.9.7k-shlib.patch
patch[1]=openssl-0.9.7c-Configure.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# shared library binary compatibility is not guaranteed
# Play it safe and up the soversion with each release
sover=12 # l = 12
abbrev_ver=$(echo $version|$SED -e 's/\.//g')
baseversion=$(echo $version|$SED -e 's/[a-zA-Z]//g')

reg prep
prep()
{
    generic_prep
    sed -e '/^SHELL/s/sh/ksh/' Makefile.org > Makefile.org.ksh
    mv Makefile.org.ksh Makefile.org
}

reg build
build()
{
    setdir source
    $SED -e "s;@LIBDIR@;${prefix}/lib;g" Makefile.org > Makefile.new
    $MV -f Makefile.new Makefile.org

    ./config --prefix=$prefix --openssldir=$prefix/ssl shared

    major=$(grep ^SHLIB_MAJOR Makefile)
    minor=$(grep ^SHLIB_MINOR Makefile)
    $SED -e "s;${major};SHLIB_MAJOR=${baseversion};g" \
	-e "s;${minor};SHLIB_MINOR=${sover};g" Makefile > Makefile.new
    $MV Makefile.new Makefile
    $SED -e "s;${major};SHLIB_MAJOR=${baseversion};g" \
	-e "s;${minor};SHLIB_MINOR=${sover};g" Makefile.ssl > Makefile.new
    $MV Makefile.new Makefile.ssl
    $MAKE_PROG CC="gcc -static-libgcc" LIBSSL="-Wl,-R,$prefix/lib -L.. -lssl" LIBCRYPTO="-Wl,-R,$prefix/lib -L.. -lcrypto" all build-shared
    $MAKE_PROG CC="gcc -static-libgcc" LIBSSL="-Wl,-R,$prefix/lib -L.. -lssl" LIBCRYPTO="-Wl,-R,$prefix/lib -L.. -lcrypto" all link-shared do_solaris-shared
}

reg install
install()
{
    setdir source
    clean stage
    $MAKE_PROG CC="gcc -static-libgcc" INSTALL_PREFIX=$stagedir LIBSSL="-Wl,-R,$prefix/lib -L.. -lssl" LIBCRYPTO="-Wl,-R,$prefix/lib -L.. -lcrypto" install
    setdir $stagedir$prefix/lib
    chmod a+x pkgconfig
    #rmdir $stagedir$prefix/ssl/lib
    $MV $stagedir$prefix/ssl/man $stagedir$prefix
    setdir $stagedir$prefix/man
    for j in $(ls -1d man?)
    do
 	cd $j
	for manpage in *
	do
	    if [ -L "${manpage}" ]; then
                TARGET=`ls -l "${manpage}" | awk '{ print $NF }'`
                ln -snf "${TARGET}"ssl "${manpage}"ssl
                rm -f "${manpage}"
	    else
		$MV "$manpage" "$manpage""ssl"
	    fi
	done
	cd ..
    done
    # A few stupid manpages left that pkgproto can't deal with
    #setdir $stagedir$prefix/man/man7
    #mv "Modes of DES.7ssl" "Modes_of_DES.7ssl"
    # Make .sos writable
    chmod 755 ${stagedir}${prefix}/${_libdir}/*.so.*
    # Nuke static libraries - they just take up space
    rm -f ${stagedir}${prefix}/${_libdir}/*.a
    rm -f ${stagedir}${prefix}/${_libdir}/fips_premain.c*
    custom_install=1
    generic_install
}

reg pack
pack()
{
    # Create depend file for openssl
    echo "P ${pkgprefix}ossl${abbrev_ver}lib	OpenSSL $version shared libraries" > $metadir/depend.openssl
    generic_pack
}

reg distclean
distclean()
{
    # depend is created by build.sh so make sure
    # it's removed by distclean
    META_CLEAN="$META_CLEAN depend.openssl"

    clean distclean
}

###################################################
# No need to look below here
###################################################
build_sh $*
