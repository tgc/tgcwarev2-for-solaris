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
version=3.3.3
pkgver=1
source[0]=$topdir-$version.tar.bz2
## If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${HOME}/buildpkg/scripts/buildpkg.functions

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
# see $metadir/pkgdef

# depend is created by build.sh so make sure
# it's removed by distclean
META_CLEAN="$META_CLEAN depend"

# We're going to build more than one package from this source
# define helpervars to do that

# Define abbreviated version number (for pkgdef)
abbrev_ver=$(echo $version|sed -e 's/\.//g') #331

# gcc base dir (for pkgdef)
gccdir=gcc-$version

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
    $srcdir/$topsrcdir/configure --prefix=/usr/local/gcc-$version --disable-nls --with-as=/usr/ccs/bin/as --with-ld=/usr/ccs/bin/ld --with-system-zlib --enable-languages=c,c++,f77,java --with-cpu=ultrasparc
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
    $MKDIR -p $stagedir$prefix/lib
    $MKDIR -p $stagedir$prefix/lib/sparcv9
    $CP $stagedir$prefix/$gccdir/lib/libgcc_s* $stagedir$prefix/lib
    $CP $stagedir$prefix/$gccdir/lib/sparcv9/libgcc_s* $stagedir$prefix/lib/sparcv9

    # Copy files for libstdc++ package
    $MKDIR -p $stagedir$prefix/lib
    $MKDIR -p $stagedir$prefix/lib/sparcv9
    $CP $stagedir$prefix/$gccdir/lib/libstdc++.so* $stagedir$prefix/lib
    $CP $stagedir$prefix/$gccdir/lib/sparcv9/libstdc++.so* $stagedir$prefix/lib/sparcv9
    rm -f $stagedir$prefix/lib/libstdc++.so
    rm -f stagedirlibstdc_stage$prefix/lib/sparcv9/libstdc++.so
    
    # now create packages according to pkgdef
    generic_pack
}

reg distclean
distclean()
{
    clean meta
    clean distclean
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
