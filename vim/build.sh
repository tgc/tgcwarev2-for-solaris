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
version=6.2.98
pkgver=gtk2-1
source[0]=$topdir-6.2.tar.bz2
# If there are no patches, simply comment this
patch[0]=6.2.001
patch[1]=6.2.002
patch[2]=6.2.003
patch[3]=6.2.005
patch[4]=6.2.006
patch[5]=6.2.007
patch[6]=6.2.008
# patch 6.2.009
patch[7]=6.2.010
patch[8]=6.2.011
patch[9]=6.2.012
# patch 6.2.13
patch[10]=6.2.014
patch[11]=6.2.015
patch[12]=6.2.016
patch[13]=6.2.017
patch[14]=6.2.018
# patch 6.2.19
patch[15]=6.2.020
patch[16]=6.2.021
# patch 6.2.22
# patch 6.2.23
# patch 6.2.24
patch[17]=6.2.025
patch[18]=6.2.026
patch[19]=6.2.027
patch[20]=6.2.028
patch[21]=6.2.029
patch[22]=6.2.030
patch[23]=6.2.031
patch[24]=6.2.032
# patch 6.2.33
patch[25]=6.2.034
patch[26]=6.2.035
# patch 6.2.36
patch[27]=6.2.037
# patch 6.2.38
# patch 6.2.39
patch[28]=6.2.040
# patch 6.2.41
# patch 6.2.42
patch[29]=6.2.043
patch[30]=6.2.044
patch[31]=6.2.045
patch[32]=6.2.046
# patch 6.2.47
patch[33]=6.2.048
patch[34]=6.2.049
patch[35]=6.2.050
patch[36]=6.2.051
patch[37]=6.2.052
patch[38]=6.2.053
patch[39]=6.2.054
patch[40]=6.2.055
# patch 6.2.56
# patch 6.2.57
patch[41]=6.2.058
patch[42]=6.2.059
# patch 6.2.60
patch[43]=6.2.061
patch[44]=6.2.062
patch[45]=6.2.063
patch[46]=6.2.064
patch[47]=6.2.065
# patch 6.2.66
patch[48]=6.2.067
patch[49]=6.2.068
patch[50]=6.2.069
patch[51]=6.2.070
patch[52]=6.2.071
patch[53]=6.2.072
patch[54]=6.2.073
patch[55]=6.2.074
patch[56]=6.2.075
patch[57]=6.2.076
patch[58]=6.2.077
patch[59]=6.2.078
patch[60]=6.2.079
patch[61]=6.2.080
patch[62]=6.2.081
patch[63]=6.2.082
patch[64]=6.2.083
patch[65]=6.2.084
patch[66]=6.2.085
patch[67]=6.2.086
patch[68]=6.2.087
patch[69]=6.2.088
patch[70]=6.2.089
# patch 6.2.90
patch[71]=6.2.091
patch[72]=6.2.092
patch[73]=6.2.093
patch[74]=6.2.094
patch[75]=6.2.095
patch[76]=6.2.096
patch[77]=6.2.097
patch[78]=6.2.098

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
    ./configure --prefix=/usr/local --with-gnome=no --enable-gui=gtk2 --disable-gpm --disable-nls
    $MAKE_PROG EXTRA_LIBS="-R /usr/local/lib"
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
