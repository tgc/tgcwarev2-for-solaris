#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=elinks
version=0.12pre6
pkgver=3
source[0]=http://elinks.or.cz/download/elinks-${version}.tar.bz2
# If there are no patches, simply comment this
patch[0]=elinks-inet_aton.patch
patch[1]=elinks-0.11.0-getaddrinfo.patch
patch[2]=elinks-0.11.0-ssl-noegd.patch
patch[3]=elinks-0.11.0-sysname.patch
patch[4]=elinks-0.11.3-macropen.patch
patch[5]=elinks-0.12pre5-ddg-search.patch
patch[6]=elinks-0.12pre6-autoconf.patch
patch[7]=elinks-0.12pre6-libidn2.patch
patch[8]=elinks-0.12pre6-list_is_singleton.patch
patch[9]=elinks-0.12pre6-openssl11.patch
patch[10]=elinks-0.12pre6-recent-gcc-versions.patch
patch[11]=elinks-0.12pre6-ssl-hostname.patch
patch[12]=elinks-0.12pre6-static-analysis.patch
patch[13]=elinks-scroll.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export PKG_CONFIG=pkgconf
export CPPFLAGS="-I$prefix/lib"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"

# No MAP_ANON for Solaris < 8
[ "$gnu_os_ver" = "2.7" ] && ac_overrides="ac_cv_func_mmap_fixed_mapped=no"
configure_args+=(--without-x --enable-256-colors)

reg prep
prep()
{
    generic_prep
    setdir source
    # rename the input file of autoconf to eliminate a warning
    mv configure.in configure.ac
    ${__gsed} -e 's/configure\.in/configure.ac/' \
	    -i Makefile* acinclude.m4 doc/man/man1/Makefile
    # remove bogus serial numbers
    ${__gsed} -i 's/^# *serial [AM0-9]*$//' acinclude.m4 config/m4/*.m4

    bash autogen.sh
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
    doc AUTHORS COPYING README SITES TODO
    ${__rmdir} ${stagedir}${prefix}/$_libdir
    ${__rm} ${stagedir}${prefix}/$_sharedir/locale/locale.alias
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
