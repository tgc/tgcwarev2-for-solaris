#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# The concept of "method" registering and the logic that implements it was shamelessly
# stolen from jhlj's Compile.sh script :)
#
# Check the following 4 variables before running the script
topdir=openssl
version=0.9.7d
pkgver=4
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=openssl-0.9.7c-shlib.patch
patch[1]=openssl-0.9.7c-Configure.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# shared library binary compatibility is not guaranteed
# Play it safe and up the soversion with each release
sover=4 # d = 4
abbrev_ver=$(echo $version|$SED -e 's/\.//g')
baseversion=$(echo $version|$SED -e 's/[a-zA-Z]//g')

# Define script functions and register them
METHODS=""
reg() {
    METHODS="$METHODS $1"
}

reg prep
prep()
{
    generic_prep
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
    rmdir $stagedir$prefix/ssl/lib
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
    setdir $stagedir$prefix/man/man7
    mv "Modes of DES.7ssl" "Modes_of_DES.7ssl"
    # Make .sos writable
    chmod 755 ${stagedir}${prefix}/${_libdir}/*.so.*
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

reg all
all()
{
    for METHOD in $METHODS 
    do
	case $METHOD in
	     all*|*clean) ;;
	     *) $METHOD
		;;
	esac
    done

}

reg
usage() {
    echo Usage $0 "{"$(echo $METHODS | tr " " "|")"}"
    exit 1
}

OK=0
for METHOD in $*
do
    METHOD=" $METHOD *"
    if [ "${METHODS%$METHOD}" == "$METHODS" ] ; then
	usage
    fi
    OK=1
done

if [ $OK = 0 ] ; then
    usage;
fi

for METHOD in $*
do
    ( $METHOD )
done
