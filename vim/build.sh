#!/usr/local/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# The concept of "method" registering and the logic that implements it was shamelessly
# stolen from jhlj's Compile.sh script :)
#
# Check the following 4 variables before running the script
topdir=vim
version=6.2.21
pkgver=motif-1
source[0]=$topdir-6.2.tar.bz2
# If there are no patches, simply comment this
patch[0]=6.2.001
patch[1]=6.2.002
patch[2]=6.2.003
patch[3]=6.2.005
patch[4]=6.2.006
patch[5]=6.2.007
patch[6]=6.2.008
# patch 6.2.009 is win32 only
patch[7]=6.2.010
patch[8]=6.2.011
patch[9]=6.2.012
# patch 6.2.13 is win32 only
patch[10]=6.2.014
patch[11]=6.2.015
patch[12]=6.2.016
patch[13]=6.2.017
patch[14]=6.2.018
# patch 6.2.19 is lang specific
patch[15]=6.2.020
patch[16]=6.2.021

# Helper var
patchcount=${#patch[@]}

# Source function library
. ${HOME}/buildpkg/scripts/buildpkg.functions

# We need to override this
topsrcdir=vim62
patchdir=$srcfiles/vim-6.2-patches

# Fill in pkginfo values if necessary
# using pkgname,name,pkgcat,pkgvendor & pkgdesc
name="Vim - Vi IMproved"
pkgvendor="http://www.vim.org"
pkgdesc="An improved almost compatible version of Vi"

# Define script functions and register them
METHODS=""
reg() {
    METHODS="$METHODS $1"
}

reg prep
prep()
{
    clean source
    unpack 0
    for ((i=0; i<patchcount; i++))
    do
	patch $i -p0
    done
}

reg build
build()
{
    setdir source
    ./configure --prefix=/usr/local --with-gnome=no --enable-gui=motif --disable-gpm --disable-nls
    $MAKE_PROG
}

reg install
install()
{
    generic_install DESTDIR
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
