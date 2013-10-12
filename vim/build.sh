#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=vim
shortver=7.4
version=${shortver}.52
pkgver=1
source[0]=ftp://ftp.vim.org/pub/vim/unix/$topdir-$shortver.tar.bz2
# If there are no patches, simply comment this
patch[0]=   # buildpkg does not handle sparse patch array
patch[1]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.001
patch[2]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.002
patch[3]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.003
patch[4]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.004
patch[5]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.005
patch[6]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.006
patch[7]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.007
patch[8]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.008
patch[9]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.009
patch[10]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.010
patch[11]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.011
patch[12]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.012
patch[13]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.013
patch[14]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.014
patch[15]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.015
patch[16]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.016
patch[17]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.017
patch[18]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.018
patch[19]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.019
patch[20]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.020
patch[21]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.021
patch[22]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.022
patch[23]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.023
patch[24]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.024
patch[25]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.025
patch[26]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.026
patch[27]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.027
patch[28]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.028
patch[29]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.029
patch[30]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.030
patch[31]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.031
patch[32]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.032
patch[33]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.033
patch[34]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.034
patch[35]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.035
patch[36]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.036
patch[37]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.037
patch[38]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.038
patch[39]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.039
patch[40]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.040
patch[41]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.041
patch[42]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.042
patch[43]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.043
patch[44]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.044
patch[45]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.045
patch[46]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.046
patch[47]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.047
patch[48]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.048
patch[49]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.049
patch[50]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.050
patch[51]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.051
patch[52]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.052

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I/usr/tgcware/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
basic_args=(--prefix=$prefix --without-local-dir --with-features=huge --enable-multibyte --disable-perlinterp --disable-pythoninterp --disable-tclinterp --with-compiledby="<swpkg@jupiterrise.com>" --disable-netbeans)
# Do not let scripts add a dependency on perl
ignore_deps="TGCperl"
# We need to override these
topsrcdir=vim74
patch_prefix="-p0"

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    # First build a gui version
    configure_args=("${basic_args[@]}" --enable-gui=motif)
    generic_build
    # Save the gui binary for later
    setdir source
    ${__cp} src/vim src/gvim
    setdir source
    ${__make} clean
    # Build without gui
    configure_args=("${basic_args[@]}" --enable-gui=no --with-x=no)
    generic_build
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    configure_args=("${basic_args[@]}" --enable-gui=motif)
    generic_install DESTDIR
    setdir source
    ${__cp} src/gvim ${stagedir}${prefix}/${_bindir}
    setdir ${stagedir}${prefix}/${_bindir}
    ${__ln} -s gvim gvimdiff
    ${__ln} -s gvim gview
    setdir ${stagedir}${prefix}/${_mandir}/man1
    ${__ln} -s vim.1 gvim.1
    ${__ln} -s vim.1 gview.1
    ${__ln} -s vimdiff.1 gvimdiff.1
    custom_install=1
    generic_install DESTDIR
    doc README.txt
    #setdir ${stagedir}${prefix}/${_sharedir}/vim/vim71/lang/
    #${__mv} "menu_chinese(gb)_gb.936.vim" "menu_chinese_gb__gb.936.vim"
    #${__mv} "menu_chinese(taiwan)_taiwan.950.vim" "menu_chinese_taiwan__taiwan.950.vim"
    ${__rm} -rf ${stagedir}${prefix}/${_mandir}/{fr,it,pl,ru,ja}*
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
