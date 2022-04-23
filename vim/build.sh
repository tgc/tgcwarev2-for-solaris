#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
patchlevel=4804
# repo_pl is always 4 digits
repo_pl=$patchlevel
basever=8.2
# Check the following 4 variables before running the script
topdir=vim
version=${basever}.${patchlevel}
pkgver=1
source[0]="https://github.com/vim/vim/archive/v${basever}.${repo_pl}.tar.gz#/${topdir}-${version}.tar.gz"
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I/usr/tgcware/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
basic_args=(--prefix=$prefix --without-local-dir --with-features=huge)
basic_args+=(--enable-multibyte --disable-perlinterp --disable-pythoninterp)
basic_args+=(--disable-tclinterp --disable-netbeans)
basic_args+=(--with-compiledby="<swpkg@jupiterrise.com>")
basic_args+=(--with-modified-by="<swpkg@jupiterrise.com>")
# Do not let scripts add a dependency on perl
ignore_deps="TGCperl"
# We need to override this
topsrcdir=vim-${basever}.${repo_pl}

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
    ${__rm} -rf ${stagedir}${prefix}/${_mandir}/{fr,it,pl,ru,ja,da,de,tr}*
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
