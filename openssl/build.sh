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
version=0.9.7c
pkgver=4
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=openssl-0.9.7c-shlib.patch
patch[1]=openssl-0.9.7c-Configure.patch
patch[2]=openssl-0.9.7c-doc.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# shared library binary compatibility is not guaranteed
# Play it safe and up the soversion with each release
sover=3 # c = 3
abbrev_ver=$(echo $version|$SED -e 's/\.//g')
baseversion=$(echo $version|$SED -e 's/[a-zA-Z]//g')

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
pkgname="$pkgprefix""ossl""$abbrev_ver"
name="OpenSSL - Secure Socket Layer"
pkgcat="application"
pkgvendor="http://www.openssl.org"
pkgdesc="Toolkit implementing SSL v2/v3 and TLS v1"

pkgname_lib="$pkgprefix""ossl""$abbrev_ver""lib"
name_lib="OpenSSL - Secure Socket Layer"
pkgcat_lib="library"
pkgvendor_lib="http://www.openssl.org"
pkgdesc_lib="Toolkit implementing SSL v2/v3 and TLS v1"

lib_stage=$BUILDPKG_BASE/$topdir/stage.lib

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
    $MAKE_PROG LIBSSL="-Wl,-R,$prefix/lib -L.. -lssl" LIBCRYPTO="-Wl,-R,$prefix/lib -L.. -lcrypto" all build-shared
    $MAKE_PROG LIBSSL="-Wl,-R,$prefix/lib -L.. -lssl" LIBCRYPTO="-Wl,-R,$prefix/lib -L.. -lcrypto" all link-shared do_solaris-shared
}

reg install
install()
{
    setdir source
    clean stage
    $MAKE_PROG INSTALL_PREFIX=$stagedir LIBSSL="-Wl,-R,$prefix/lib -L.. -lssl" LIBCRYPTO="-Wl,-R,$prefix/lib -L.. -lcrypto" install
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
    setdir $stagedir$prefix/man/man3
    mv "EVP_MD_CTX_copy_ex EVP_MD_CTX_copy.3ssl" "EVP_MD_CTX_copy_ex_EVP_MD_CTX_copy.3ssl"
    mv "UI_construct_prompt UI_add_user_data.3ssl" "UI_construct_prompt_UI_add_user_data.3ssl"
    setdir $stagedir$prefix/man/man7
    mv "Modes of DES.7ssl" "Modes_of_DES.7ssl"
}

reg pack
pack()
{
    # Split up the stagedir
    # The bare .so and .a used for development should only be available
    # if the matching headers etc. is installed so they're not put in the lib package
    mkdir -p $lib_stage$prefix/lib
    $MV $stagedir$prefix/lib/*.so.* $lib_stage$prefix/lib

    # Create runtime package
    echo "P $pkgname_lib	$name_lib" > $metadir/depend
    generic_pack

    usedepend=0
    $MV $stagedir $stagedir.1
    $MV $lib_stage $stagedir
    pkgname=$pkgname_lib
    name=$name_lib
    pkgcat=$pkgcat_lib
    pkgvendor=$pkgvendor_lib
    pkgdesc=$pkgdesc_lib

    distfile=$topdir-lib-$version-$pkgver.sb-$os-$cpu-$pkgdirdesig
    generic_pack

    $MV $stagedir.1 $stagedir
    setdir source
    clean stage
}

reg distclean
distclean()
{
    # depend is created by build.sh so make sure
    # it's removed by distclean
    META_CLEAN="$META_CLEAN depend"

    clean distclean
    pkgname=$pkgname_lib
    clean meta
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
