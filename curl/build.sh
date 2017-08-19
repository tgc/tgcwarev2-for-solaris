#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=curl
version=7.55.1
pkgver=1
source[0]=http://curl.haxx.se/download/$topdir-$version.tar.bz2
# https://curl.haxx.se/docs/caextract.html
certdate=2017-06-07
source[1]=https://curl.haxx.se/ca/cacert-$certdate.pem
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"

configure_args+=(--enable-static=no --enable-http --enable-ftp --enable-file --disable-ldap --enable-manual --enable-cookies --enable-crypto --with-libidn2 --with-libssh2 --with-ca-bundle=${prefix}/${_sysconfdir}/curl-ca-bundle.pem)

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

reg check
check()
{
    generic_check
}

reg install
install()
{
    generic_install DESTDIR
    ${__install} -m0644 -D $(get_source_absfilename "${source[1]}") ${stagedir}${prefix}/${_sysconfdir}/curl-ca-bundle.pem
    doc CHANGES COPYING README* RELEASE-NOTES docs/FAQ docs/FEATURES docs/BUGS \
      docs/MANUAL docs/RESOURCES docs/TODO docs/TheArtOfHttpScripting \
      docs/examples/*.c docs/examples/Makefile.example

    compat curl 7.29.0 1 1
    compat curl 7.30.0 1 1
    compat curl 7.33.0 1 1
    compat curl 7.35.0 1 1
    compat curl 7.36.0 1 1
    compat curl 7.38.0 1 1
    compat curl 7.41.0 1 1
    compat curl 7.42.0 1 1
    compat curl 7.42.1 1 1
    compat curl 7.44.1 1 1
    compat curl 7.46.0 1 1
    compat curl 7.47.1 1 2
    compat curl 7.48.0 1 1
    compat curl 7.49.0 1 1
    compat curl 7.49.1 1 1
    compat curl 7.50.0 1 1
    compat curl 7.50.3 1 1
    compat curl 7.51.0 1 1
    compat curl 7.52.1 1 1
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
