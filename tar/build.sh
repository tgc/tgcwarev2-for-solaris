#!/usr/local/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# The concept of "method" registering and the logic that implements it was shamelessly
# stolen from jhlj's Compile.sh script :)
#
# Check the following 4 variables before running the script
topdir=tar
version=1.13.25
pkgver=2
source[0]=$topdir-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=tar-1.13.18-manpage.patch
patch[1]=tar-1.13.19-absolutenames.patch
patch[2]=tar-1.13.19-error.patch
patch[3]= #tar-1.13.22-nolibrt.patch
patch[4]=tar-1.13.25-argv.patch
patch[5]= #tar-1.13.25-autoconf.patch
patch[6]=tar-1.13.25-dots.patch
patch[7]=tar-1.13.25-sock.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
name="GNU tar"
pkgcat="application"
pkgvendor="http://www.gnu.org"
pkgdesc="Creates tar archives"

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
    generic_build
}

reg install
install()
{
    generic_install DESTDIR
    $RM -f $stagedir$prefix/info/dir
    INSTALL="/usr/local/bin/install -D"
    setdir source
    $INSTALL -m 644 tar.1 $stagedir$prefix/man/man1/tar.1
    
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
