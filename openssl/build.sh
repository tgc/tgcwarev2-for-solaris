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
version=0.9.6k
pkgver=1
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=openssl-0.9.6k-soversion.patch
patch[1]=openssl-0.9.6k-Configure.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

abbrev_ver=$(echo $version|sed -e 's/\.//g')

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
pkgname=SBossl$abbrev_ver
name="OpenSSL - Secure Socket Layer"
pkgcat="application"
pkgvendor="http://www.openssl.org"
pkgdesc="Toolkit implementing SSL v2/v3 and TLS v1"

pkgname_lib=SBossl$abbrev_ver"lib"
name_lib="OpenSSL - Secure Socket Layer"
pkgcat_lib="library"
pkgvendor_lib="http://www.openssl.org"
pkgdesc_lib="Toolkit implementing SSL v2/v3 and TLS v1"

# shared library binary compatibility is not guaranteed
# Play it safe and up the soversion with each release
# 0.9.6(a-b) is sover 2 (RH)
# 0.9.6c-j was never built at SB with sh libs
# 0.9.6k is sover 3 (RH uses this for 0.9.6c)
# 0.9.7a is sover 4 (on RH, never built with sh libs on SB)
# 0.9.7b is sover 5 (never built at SB)
# 0.9.7c is sover 6

baseversion=0.9.6
sover=2
liblist="libssl libcrypto"

lib_stage=$BUILDPKG_BASE/$topdir/stage.lib

MV=mv

# Define script functions and register them
METHODS=""
reg() {
    METHODS="$METHODS $1"
}

reg prep
prep()
{
    generic_prep
    # Set correct sover in Makefile.org
    perl -i -pe "s/SHLIB_SOVER\=/SHLIB_SOVER\=$sover/g" $srcdir/$topsrcdir/Makefile.org
}

reg build
build()
{
    setdir source
    ./config --prefix=$prefix --openssldir=$prefix/ssl shared
    $MAKE_PROG
#    $MAKE_PROG -C test apps tests
}

reg install
install()
{
    setdir source
    clean stage
    $MAKE_PROG INSTALL_PREFIX=$stagedir install build-shared
    setdir $stagedir$prefix/lib
    chmod a+x pkgconfig
    for i in $liblist
    do
	$MV $i.so.$baseversion $i.so.$version
	rm -f $i.so.$sover
	rm -f $i.so
	ln -s $i.so.$version $i.so.$sover
	ln -s $i.so.$sover $i.so
    done
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
    #setdir $stagedir$prefix/man/man3
    #mv "EVP_MD_CTX_copy_ex EVP_MD_CTX_copy.3ssl" "EVP_MD_CTX_copy_ex_EVP_MD_CTX_copy.3ssl"
    #mv "UI_construct_prompt UI_add_user_data.3ssl" "UI_construct_prompt_UI_add_user_data.3ssl"
    #setdir $stagedir$prefix/man/man7
    #mv "Modes of DES.7ssl" "Modes_of_DES.7ssl"
}

reg pack
pack()
{
    # Split up the stagedir
    # The bare .so and .a used for development should only be available
    # if the matching headers etc. is installed so they're not put in the lib package
    mkdir -p $lib_stage$prefix/lib
    $MV $stagedir$prefix/lib/*.so.* $lib_stage$prefix

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
