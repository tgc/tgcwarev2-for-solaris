#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=sudo
version=1.8.32
pkgver=1
source[0]=https://www.sudo.ws/sudo/dist/$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
configure_args+=(--sysconfdir=/usr/tgcware/etc --with-man --with-all-insults)

reg prep
prep()
{
    generic_prep
    setdir source
    ${__gsed} -i "/^install_uid/ s/0/$(id -u)/" Makefile.in
    ${__gsed} -i "/^install_gid/ s/0/$(id -u)/" Makefile.in
    # Configure adds closefrom_fallback into the linker export map as a global
    # but that function is static void meaning it cannot possibly be a global
    # symbol. Later gcc/linker combos on Solaris seems not to care but gcc with
    # the Solaris 7 linker will fail with a symbol reference error when parsing
    # the mapfile.
    ${__gsed} -i 's/closefrom_fallback//' configure
}

reg build
build()
{
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
    ${__mv} ${stagedir}${prefix}/share/doc/sudo ${stagedir}${prefix}/${_vdocdir}
    ${__rm} -f ${stagedir}${prefix}/etc/sudoers
}

reg pack
pack()
{
    lprefix=${prefix#/*}
    topinstalldir=/
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
