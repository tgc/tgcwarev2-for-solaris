#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
snapshot=
topdir=gcc
version=4.4.7
pkgver=1
source[0]=ftp://ftp.sunet.se/pub/gnu/gcc/releases/$topdir-$version/$topdir-$version.tar.bz2
## If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
lprefix=$prefix
[ -n "$snapshot" ] && topsrcdir=gcc-$version-$snapshot
__configure="../$topsrcdir/configure"

# Define abbreviated version number (for pkgdef)
abbrev_ver=$(echo $version | ${__tr} -d '.')
# Just major.minor, no subminors
majorminor=$(echo $version | cut -d. -f1-2)
abbrev_majorminor=$(echo $majorminor | tr -d '.')

prefix=${lprefix}/${topdir}${abbrev_majorminor}

# In /usr/tgcware/gcc44 goes bin, man, info
# everything else goes to /usr/tgcware lib,libexec,include,share
# java/gcj has some files in lib that are unversioned and could
# cause conflicts if multiple versions are attempted to be installed
# local-prefix continues to be a noop since I don't want
# anything to override <prefix>/include automatically

global_config_args="--prefix=$lprefix --with-local-prefix=$prefix --bindir=${prefix}/bin --mandir=${prefix}/man --infodir=${prefix}/info --with-libiconv-prefix=$lprefix --with-gmp=$lprefix --with-mpfr=$lprefix --disable-nls --enable-shared --enable-threads=posix"
langs="--enable-languages=all,ada,obj-c++"
linker="--without-gnu-ld --with-ld=/usr/ccs/bin/ld"
assembler="--without-gnu-as --with-as=/usr/ccs/bin/as"
objdir=all_native
# platform/arch specific options
[ "$arch" = "i386" ] && { assembler="--with-gnu-as --with-as=$lprefix/bin/gas"; cpu="--with-arch-32=i686 --with-tune-32=i686"; }
[ "$arch" = "sparc" ] && { vendor="sun"; sparc=1; } || { vendor="pc"; intel=1; }
[ "$arch" = "sparc" -a -n "$(isalist | grep sparcv9)" ] && { sparcv9=1; m64run=1; } || m64run=0

platform_configure_args="$cpu"

gnu_os_ver=$(${__uname} -r | ${__sed} -e 's/^5/2/')

# Languages (add Java specific opts)
langs="$langs --with-x --with-java-awt=xlib --with-system-zlib"
java_libver=10

configure_args="$global_config_args $linker $assembler $langs $platform_configure_args"

# RPATH with just $lprefix since this is where lib goes
# This *may* pose a problem during bootstrap and in that case a two stage bootstrap will be needed.
# This forces all linked objects including libraries (ie. libstdc++.so) to have an RPATH
export LD_OPTIONS="-R$lprefix/lib -R$lprefix/lib/\$ISALIST"

# As documented ksh or better is needed
export CONFIG_SHELL=/bin/ksh

# Setup tool path
export PATH=$srcdir/tools:$PATH

# Creates tool path
setup_tools()
{
    # Setup tools
    # On Solaris 8 /usr/xpg4/bin/grep mishandles long lines
    # Use /usr/bin/grep instead (or even better GNU grep)
    # For Java we need GNU diff and GNU find
    # For C++/libstdc++ we need c++filt
    # We need a reasonably new jar, jar from Java 1.2 will not work
    # GNU sed is not a bad idea either
    # Go needs objcopy
    # Atleast some configure tests depend on objdump
    ${__mkdir} -p $srcdir/tools
    setdir $srcdir/tools
    ${__ln_s} -f /usr/bin/grep grep
    ${__ln_s} -f /opt/csw/bin/gdiff diff
    ${__ln_s} -f /opt/csw/bin/gfind find
    ${__ln_s} -f /opt/csw/bin/gsed sed
    ${__ln_s} -f /opt/csw/gcc4/bin/gjar jar
    ${__ln_s} -f /usr/tgcware/bin/gc++filt c++filt
    ${__ln_s} -f /usr/tgcware/bin/gobjcopy objcopy
    ${__ln_s} -f /usr/tgcware/bin/gobjdump objdump
}

datestamp()
{
    date +%Y%m%d%H%M
}

reg prep
prep()
{
    datestamp
    generic_prep
    setup_tools
    datestamp
}

reg build
build()
{
    datestamp
    setup_tools
    setdir source
    ${__mkdir} -p ../$objdir
    echo "$__configure $configure_args"
#    setdir ../$objdir
#    ${__make}
    generic_build ../$objdir
    datestamp
}

reg install
install()
{
    datestamp
    setup_tools
    clean stage
    setdir ${srcdir}/${objdir}
    ${__make} DESTDIR=$stagedir install
    custom_install=1
    generic_install
    ${__find} ${stagedir} -name '*.la' -print | ${__xargs} ${__rm} -f

    # Lots of rearranging to do to make multiple GCC versions work
    # This is based on the rhel6 and Fedora current specfiles
    # First we need to move all gcc version specific files/libraries to the private versioned
    # libdir
    FULLPATH=${stagedir}${lprefix}/lib/gcc/${arch}-${vendor}-solaris${gnu_os_ver}/${version}
    setdir $FULLPATH
    ${__mv} ../../../libgfortran.a .
    ${__mv} ../../../libgomp.a .
    ${__mv} ../../../libgomp.spec .
    ${__mv} ../../../libffi.a .
    ${__mv} ../../../libiberty.a .
    ${__mv} ../../../libstdc++.a .
    ${__mv} ../../../libsupc++.a .
    ${__mv} ../../../libssp*.a .
    ${__mv} ../../../libobjc.a .
    # Remove .so
    ${__rm} -f ../../../libffi.so
    ${__rm} -f ../../../libgcc_s.so
    ${__rm} -f ../../../libgfortran.so
    ${__rm} -f ../../../libgomp.so
    ${__rm} -f ../../../libobjc.so
    ${__rm} -f ../../../libssp.so
    ${__rm} -f ../../../libstdc++.so
    # Create new .so files, note we link not to the full version
    # since we want to cheat and allow newer compilers to upgrade
    # them as long as the soversion is matching
    ${__ln_s} ../../../libffi.so.4 libffi.so
    ${__ln_s} ../../../libgcc_s.so.1 libgcc_s.so
    ${__ln_s} ../../../libgfortran.so.3 libgfortran.so
    ${__ln_s} ../../../libgomp.so.1 libgomp.so
    ${__ln_s} ../../../libobjc.so.2 libobjc.so
    ${__ln_s} ../../../libssp.so.0 libssp.so
    ${__ln_s} ../../../libstdc++.so.6 libstdc++.so
    # For Ada
    ${__mv} adalib/libgnarl-*.so ../../../
    ${__mv} adalib/libgnat-*.so ../../../
    ${__rm} -f adalib/libgnat.so adalib/libgnarl.so
    ${__ln_s} ../../../libgnarl-*.so libgnarl.so
    ${__ln_s} ../../../libgnat-*.so libgnat.so
    cd $FULLPATH/adalib
    ${__ln_s} ../../../../libgnarl-*.so libgnarl.so
    ${__ln_s} ../../../../libgnarl-*.so libgnarl-4.4.so
    ${__ln_s} ../../../../libgnat-*.so libgnat.so
    ${__ln_s} ../../../../libgnat-*.so libgnat-4.4.so
    cd ..
    # Ada will not work without these symlinks
    mkdir -p ${stagedir}${prefix}/lib/gcc/${arch}-${vendor}-solaris${gnu_os_ver}/${version}
    cd ${stagedir}${prefix}/lib/gcc/${arch}-${vendor}-solaris${gnu_os_ver}/${version}
    ${__ln_s} ../../../../../lib/gcc/${arch}-${vendor}-solaris${gnu_os_ver}/${version}/adainclude .
    ${__ln_s} ../../../../../lib/gcc/${arch}-${vendor}-solaris${gnu_os_ver}/${version}/adalib .

    # Turn all the hardlinks in bin into symlinks
    setdir ${stagedir}${prefix}/${_bindir}
    for i in c++ ${arch}-${vendor}-solaris*-c++ ${arch}-${vendor}-solaris*-g++
    do
	${__rm} -f $i
        ${__ln} -sf g++ $i
    done
    for i in ${arch}-${vendor}-solaris*-gcc ${arch}-${vendor}-solaris*-gcc-$version
    do
	${__rm} -f $i
        ${__ln} -sf gcc $i
    done
    for i in ${arch}-${vendor}-solaris*-gfortran
    do
	${__rm} -f $i
        ${__ln} -sf gfortran $i
    done
    for i in ${arch}-${vendor}-solaris*-gcj
    do
	${__rm} -f $i
        ${__ln} -sf gcj $i
    done

    # Java python bits are in the wrong place
    ${__mkdir} -p ${stagedir}${lprefix}/share/gcc-${version}/python/libjava
    ${__mv} ${stagedir}${lprefix}/share/python/{aotcompile,classfile}.py ${stagedir}${lprefix}/share/gcc-${version}/python/libjava
    ${__rmdir} ${stagedir}${lprefix}/share/python

    # Place share/docs in the regular location
    prefix=$topinstalldir
    doc COPYING* MAINTAINERS NEWS
   
    # Create compat data
    ${__rm} -f $metadir/compver.*
    for ver in 4.3.6
    do
	compat libstdc++6 $ver 2 10
	compat libssp0 $ver 2 10
	compat libffi4 $ver 2 10
	compat libgomp1 $ver 2 10
	compat libgfortran3 $ver 2 10
	compat libobjc2 $ver 2 10
	compat libgcc_s1 $ver 2 10
    done

    datestamp
}

reg check
check()
{
    datestamp
    setup_tools
    setdir source
    setdir ../$objdir
    # If we can run v9 binaries then we also run the testsuite with -m64
    if [ $m64run -eq 0 ]; then
	${__make} -k check
    else
	echo "Running the testsuite also with -m64"
	${__make} -k RUNTESTFLAGS="--target_board='unix{,-m64}'" check
    fi
    datestamp
}

reg pack
pack()
{
    datestamp
    iprefix=${topdir}${abbrev_majorminor}
    generic_pack
    datestamp
}

reg distclean
distclean()
{
    META_CLEAN="$META_CLEAN compver.*"
    clean distclean
    setdir $srcdir
    ${__rm} -rf $objdir
}

###################################################
# No need to look below here
###################################################
build_sh $*
