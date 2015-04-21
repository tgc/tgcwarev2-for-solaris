#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
hgrev=e026e4f106a5
patchlevel=703
basever=7.4
# Check the following 4 variables before running the script
topdir=vim
version=${basever}.${patchlevel}
pkgver=1
# Tarball was created like this:
# hg clone https://vim.googlecode.com/hg/ vim
# hg archive -r v7-4-%{patchlevel} %b-%h.tar.bz2
source[0]=$topdir-$hgrev.tar.bz2
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I/usr/tgcware/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
basic_args=(--prefix=$prefix --without-local-dir --with-features=huge --enable-multibyte --disable-perlinterp --disable-pythoninterp --disable-tclinterp --with-compiledby="<swpkg@jupiterrise.com>" --disable-netbeans)
# Do not let scripts add a dependency on perl
ignore_deps="TGCperl"
# We need to override this
topsrcdir=vim-${hgrev}

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
