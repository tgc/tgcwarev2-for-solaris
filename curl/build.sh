#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=curl
version=8.8.0
pkgver=1
source[0]=https://curl.se/download/$topdir-$version.tar.xz
# https://curl.se/docs/caextract.html
certdate=2024-03-11
source[1]=https://curl.se/ca/cacert-$certdate.pem
# If there are no patches, simply comment this
# OpenSSH 8.8 disabled sha1 rsa out of the box
patch[0]=curl-7.82.0-modern-openssh.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
export PKG_CONFIG=pkgconf

configure_args+=(--enable-static=no --with-openssl --enable-http --enable-ftp --enable-file --disable-ldap --enable-manual --enable-cookies --with-libidn2 --with-libssh2 --with-nghttp2 --with-ca-bundle=${prefix}/${_sysconfdir}/curl-ca-bundle.pem)

# The threaded resolver does not work on Solaris 7
[ "$_os" = "sunos57" ] && configure_args+=( --disable-threaded-resolver)

reg prep
prep()
{
    generic_prep
    setdir source
    # Ensure testsuite can find sshd
    sed -i 's#/usr/freeware#/usr/tgcware#' tests/sshhelp.pm
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
    doc CHANGES COPYING README* RELEASE-NOTES docs/FAQ docs/FEATURES.md docs/BUGS.md \
      docs/TODO docs/TheArtOfHttpScripting.md \
      docs/examples/*.c docs/examples/Makefile.example

    # ABI compatible releases
    compat curl 7.47.1 1 2
    for release in \
	7.29.0 7.30.0 7.33.0 7.35.0 7.36.0 7.38.0 7.41.0 7.42.0 7.42.1 \
	7.44.1 7.46.0 7.48.0 7.49.0 7.49.1 7.50.0 7.50.3 7.51.0 7.52.1 \
	7.55.1 7.59.0 7.61.1 7.64.0 7.64.1 7.69.1 7.73.0 7.75.0 7.76.0 \
	7.76.1 7.79.1 7.82.0 7.83.1 7.86.0 7.87.1 8.2.0 8.3.0 8.4.0
    do
	compat curl $release 1 1
    done
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
