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
version=6.3.4
pkgver=1
source[0]=$topdir-6.3.tar.bz2
# If there are no patches, simply comment this
patch[0]=6.3.001
patch[1]=6.3.002
patch[2]=6.3.003
patch[3]=6.3.004

# Helper var
patchcount=${#patch[@]}

# Source function library
. ${HOME}/buildpkg/scripts/buildpkg.functions

# We need to override this
topsrcdir=vim63
patchdir=$srcfiles/vim-6.3-patches

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
    export EXTRA_LIBS="-R/usr/local/lib"
    # Build gvim
    configure_args='--prefix=$prefix --enable-gui=motif --disable-gpm --disable-nls --with-features=huge --with-compiledby="<tgc@statsbiblioteket.dk>" --enable-multibyte'
    generic_build
    setdir source
    cd src
    $CP vim gvim
    $MAKE_PROG clean
    # Build text-based vim
    configure_args='--prefix=$prefix --with-x=no --enable-gui=no --disable-gpm --disable-nls --with-features=huge --with-compiledby="<tgc@statsbiblioteket.dk>" --enable-multibyte'
    generic_build
}

reg install
install()
{
    generic_install DESTDIR
    setdir source
    $CP src/gvim ${stagedir}${prefix}/${_bindir}
    setdir ${stagedir}${prefix}/${_bindir}
    ln -s gvim gvimdiff
    ln -s gvim gview
    setdir ${stagedir}${prefix}/${_mandir}/man1
    ln -s vim.1 gvim.1
    ln -s vim.1 gview.1
    ln -s vimdiff.1 gvimdiff.1
    strip
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
