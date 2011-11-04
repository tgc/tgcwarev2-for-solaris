#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=vim
version=7.2
pkgver=1
source[0]=ftp://ftp.vim.org/pub/vim/unix/$topdir-$version.tar.bz2
# If there are no patches, simply comment this
# Generate rough patchlist like this:
# grep -v Win32 README | grep -v VMS | grep -v Mac | grep -v \.gz |grep -v \(extra|awk '{ print $2 }'|grep 7.1
# Unfortunately the markers are misleading and several Mac, Win32 and extra patches need also to be applied
# num=0; for i in `grep -v Win32 README | grep -v VMS | grep -v Mac | grep -v \.gz |grep -v \(extra|awk '{ print $2 }'|grep 7.1`; do echo "patch[$num]=$i"; let num=num+1; done

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
# We need to override this
topsrcdir=vim72
patchdir=$srcfiles/vim-${version}-patches
patch_prefix="-p0"
export CPPFLAGS="-I/usr/tgcware/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
# What gui should we build?
gui=motif
configure_args='--prefix=$prefix --without-local-dir --enable-gui=$gui --with-features=huge --enable-multibyte --disable-perlinterp --disable-pythoninterp --disable-tclinterp --with-compiledby="<swpkg@jupiterrise.com>" --disable-netbeans'

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    # First build a gui version
    gui=motif
    generic_build
    # Save the gui binary for later
    setdir source
    ${__cp} src/vim src/gvim
    setdir source
    ${__make} clean
    gui="no --with-x=no"
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
    ${__rm} -rf ${stagedir}${prefix}/${_mandir}/{fr,it,pl,ru}*
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
