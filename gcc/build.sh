#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# The concept of "method" registering and the logic that implements it was shamelessly
# stolen from jhlj's Compile.sh script :)
#
# Check the following 4 variables before running the script
topdir=gcc
version=3.3.1
pkgver=3
source[0]=$topdir-$version.tar.bz2
## If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${HOME}/buildpkg/scripts/buildpkg.functions

# Define abbreviated version number
abbrev_ver=$(echo $version|sed -e 's/\.//g') #331

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
pkgname="$pkgprefix""gcc""$abbrev_ver"
name="GCC - GNU Compiler Collection"
pkgvendor="http://gcc.gnu.org"
pkgdesc="GNU Compiler Collection (C, C++)"

# depend is created by build.sh so make sure
# it's removed by distclean
META_CLEAN="$META_CLEAN depend"

# We're going to build more than one package from this source
# define helpervars to do that
libgcc_stage=$BUILDPKG_BASE/$topdir/stage.libgcc
gcc_dir=$prefix/gcc-$version
libgcc_pkgname="$pkgprefix""libgcc""$abbrev_ver"
libgcc_name="libgcc - GCC runtime support"
libgcc_pkgcat="library"
libgcc_pkgvendor="http://gcc.gnu.org"
libgcc_pkgdesc="Runtime support for programs built with gcc 3.x"
libgcc_pkgver="3"

libstdc_stage=$BUILDPKG_BASE/$topdir/stage.libstdc
libstdc_pkgname="$pkgprefix""libstdc""$abbrev_ver"
libstdc_name="libstdc++ - GCC runtime support"
libstdc_pkgcat="library"
libstdc_pkgvendor="http://gcc.gnu.org"
libstdc_pkgdesc="Runtime support for c++ programs built with gcc $version"
libstdc_pkgver="3"

MV=/usr/bin/mv
CP=/usr/bin/cp

objdir=$srcdir/objdir

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
    $MKDIR "$objdir"
    setdir "$objdir"
    $srcdir/$topsrcdir/configure --prefix=/usr/local/gcc-$version --disable-nls --with-as=/usr/ccs/bin/as --with-ld=/usr/ccs/bin/ld --with-system-zlib --enable-languages=c,c++
    $MAKE_PROG
}

reg install
install()
{
    setdir $objdir
    $MAKE_PROG DESTDIR=$stagedir install
}

reg pack
pack()
{
    usedepend=0	# don't use $metadir/depend file

    # We want to create gcc, libstdc++ and libgcc packages
    # Copy files for libgcc package
    $MKDIR -p $libgcc_stage$prefix/lib
    $MKDIR -p $libgcc_stage$prefix/lib/sparcv9
    $CP $stagedir$gcc_dir/lib/libgcc_s* $libgcc_stage$prefix/lib
    $CP $stagedir$gcc_dir/lib/sparcv9/libgcc_s* $libgcc_stage$prefix/lib/sparcv9

    # Copy files for libstdc++ package
    $MKDIR -p $libstdc_stage$prefix/lib
    $MKDIR -p $libstdc_stage$prefix/lib/sparcv9
    $CP $stagedir$gcc_dir/lib/libstdc++.so* $libstdc_stage$prefix/lib
    $CP $stagedir$gcc_dir/lib/sparcv9/libstdc++.so* $libstdc_stage$prefix/lib/sparcv9
    #rm -f $libstdc_stage$prefix/lib/libstdc++.so.5
    #rm -f $libstdc_stage$prefix/lib/sparcv9/libstdc++.so.5
    rm -f $libstdc_stage$prefix/lib/libstdc++.so
    rm -f $libstdc_stage$prefix/lib/sparcv9/libstdc++.so
    
    # now create gcc package
    generic_pack

    # Prepare for libgcc package
    $MV $stagedir $stagedir.1
    $MV $libgcc_stage $stagedir
    pkgname=$libgcc_pkgname
    name=$libgcc_name
    pkgcat=$libgcc_pkgcat
    pkgvendor=$libgcc_pkgvendor
    pkgdesc=$libgcc_pkgdesc
    pkgver=$libgcc_pkgver

    distfile=libgcc-$version-$pkgver.sb-$os-$cpu-$pkgdirdesig
    generic_pack # don't embed any pre/post scripts

    # Prepare for libstdc++ package
    $MV $stagedir $libgcc_stage
    $MV $libstdc_stage $stagedir
    pkgname=$libstdc_pkgname
    name=$libstdc_name
    pkgcat=$libstdc_pkgcat
    pkgvendor=$libstdc_pkgvendor
    pkgdesc=$libstdc_pkgdesc
    pkgver=$libstdc_pkgver

    distfile=libstdc++-$version-$pkgver.sb-$os-$cpu-$pkgdirdesig
    usedepend=0
    generic_pack
    
    # clean up $stagedir
    # We will need to do build.sh install to use it again since we've moved files around
    # so we might as well nuke it now
    $MV $stagedir.1 $stagedir # move gcc stagedir into the current stagedir
    $MV $libgcc_stage $stagedir # move libgcc stagedir into the current stagedir
    setdir source
    clean stage  # Nuke all of it :)
}

reg distclean
distclean()
{
    clean distclean
    pkgname=$libgcc_pkgname
    clean meta
    pkgname=$libstdc_pkgname
    clean meta
    $RM -rf $objdir
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
