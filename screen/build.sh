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
topdir=screen
version=4.0.3
pkgver=1
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=screen-4.0.2-makefile-madness.diff

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Global settings

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
    setdir source
    ${__cp} terminfo/screeninfo.src $stagedir$prefix/share/$topdir
    ${__mkdir} -p $stagedir$prefix/etc
    ${__cp} etc/etcscreenrc $stagedir$prefix/etc/screenrc
    # Add two useful hacks to screenrc
    cat << EOF >> $stagedir$prefix/etc/screenrc
# special xterm hardstatus: use the window title.
termcapinfo xterm 'hs:ts=\E]2;:fs=\007:ds=\E]2;screen\007'

hardstatus string "[screen %n%?: %t%?] %h"
EOF
    doc NEWS README doc/README.DOTSCREEN doc/FAQ
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
build_sh $*
