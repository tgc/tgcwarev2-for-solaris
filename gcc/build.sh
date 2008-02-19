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
topdir=gcc
version=3.3.6
pkgver=1
source[0]=$topdir-$version.tar.bz2
## If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${HOME}/buildpkg/scripts/buildpkg.functions

# Global settings
prefix=/usr/local
configure_args="--prefix=${prefix}/gcc-$version --disable-nls --with-as=/usr/ccs/bin/as --with-ld=/usr/ccs/bin/ld --with-system-zlib --enable-languages=c,c++,f77 --with-cpu=ultrasparc"

objdir=$srcdir/objdir

# Define abbreviated version number (for pkgdef)
abbrev_ver=$(echo $version|sed -e 's/\.//g')

# gcc base dir (for pkgdef)
gccdir=gcc-$version

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
    $srcdir/$topsrcdir/configure $configure_args
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
    # We want to create gcc, libstdc++ and libgcc packages
    # Copy files for libgcc package
    $MKDIR -p ${stagedir}${prefix}/lib
    $MKDIR -p ${stagedir}${prefix}/lib/sparcv9
    $CP ${stagedir}${prefix}/$gccdir/lib/libgcc_s.so.1 ${stagedir}${prefix}/lib
    $CP ${stagedir}${prefix}/$gccdir/lib/sparcv9/libgcc_s.so.1 ${stagedir}${prefix}/lib/sparcv9

    # Copy files for libstdc++ package
    $MKDIR -p ${stagedir}${prefix}/lib
    $MKDIR -p ${stagedir}${prefix}/lib/sparcv9
    $CP ${stagedir}${prefix}/$gccdir/lib/libstdc++.so.* ${stagedir}${prefix}/lib
    $CP ${stagedir}${prefix}/$gccdir/lib/sparcv9/libstdc++.so.* ${stagedir}${prefix}/lib/sparcv9
#    rm -f ${stagedir}${prefix}/lib/libstdc++.so
#    rm -f ${stagedir}${prefix}/lib/sparcv9/libstdc++.so
    
    # now create packages according to pkgdef
    generic_pack
}

reg distclean
distclean()
{
    clean distclean
    $RM -rf $objdir
}

###################################################
# No need to look below here
###################################################
build_sh $*
