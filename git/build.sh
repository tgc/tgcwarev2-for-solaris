#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=git
version=2.36.3
pkgver=1
source[0]=https://www.kernel.org/pub/software/scm/git/$topdir-$version.tar.gz
source[1]=https://www.kernel.org/pub/software/scm/git/$topdir-manpages-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=0001-Ensure-INET_ADDRSTRLEN-is-defined.patch
patch[1]=0002-Ensure-SCNuMAX-is-defined.patch
patch[2]=0003-Update-common-Solaris-settings.patch
patch[3]=0004-Use-largefile-environment-on-Solaris.patch
patch[4]=0005-Update-settings-for-Solaris.patch
patch[5]=0006-No-pthread-support-for-Solaris-2.6.patch
patch[6]=0007-Solaris-2.6-needs-libresolv.patch
patch[7]=0008-Use-better-shell-in-t5545.patch
patch[8]=0009-Use-better-shell-in-t5801-helper.patch
patch[9]=0010-Avoid-stdint.h.patch
patch[10]=0011-Workaround-for-fileno-being-a-macro.patch
[ $(uname -r) = "5.7" ] && patch[11]=0012-UTC-is-GMT-on-Solaris-8.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Consistently failing tests
# Solaris <= 9
#t3701.53 - diffFilter filters diff
# Solaris <= 8
#t8010.9 - cat-file --textconv --batch works
# cat-file --textconv is buggy. As soon as the textconv command is triggered on
# an input line all subsequent input lines are dropped from the output.

# Global settings
no_configure=1
__configure="make"
configure_args=
make_check_target="test V=1"
make_build_target="V=1"

reg prep
prep()
{
    generic_prep
    setdir source
    cat << EOF > config.mak
V=1
prefix=$prefix
CC=gcc
SHELL=$prefix/bin/bash
PERL_PATH=$prefix/bin/perl
SHELL_PATH=$prefix/bin/bash
SANE_TOOL_PATH=/usr/tgcware/gnu:/usr/xpg6/bin:/usr/xpg4/bin
BASIC_CFLAGS+=-std=gnu99
BASIC_CFLAGS+=-I$prefix/include
BASIC_LDFLAGS+=-L$prefix/lib -R$prefix/lib
PTHREAD_CFLAGS=-pthread
INSTALL=/usr/tgcware/bin/ginstall
TAR=/usr/tgcware/bin/gtar
USE_LIBPCRE=YesPlease
NEEDS_LIBICONV=YesPlease
ICONVDIR=$prefix
NO_INSTALL_HARDLINKS=YesPlease
NO_PYTHON=YesPlease
# It takes forever to run SVN tests
NO_SVN_TESTS=YesPlease
# Bypass curl-config
CURLDIR=$prefix
CURL_LDFLAGS=-lcurl
# This is a safe choice for Solaris < 9 where /dev/urandom requires either a
# patch or a third party kernel driver like ANDIrand
CSPRNG_METHOD=openssl
# Test options
DEFAULT_TEST_TARGET=prove
GIT_PROVE_OPTS=--timer --jobs 4 --state=save --statefile=$srcdir/$topsrcdir/.prove
EOF

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
    mkdir -p ${stagedir}${prefix}/${_mandir}
    setdir ${stagedir}${prefix}/${_mandir}
    ${__tar} -xf $(get_source_absfilename "${source[1]}")
    chmod 755 ${stagedir}${prefix}/${_mandir}
    doc COPYING Documentation/RelNotes/${version}.txt README.md

    # fix git symlink
    ${__rm} -f ${stagedir}${prefix}/libexec/git-core/git
    ${__ln} -s ${prefix}/${_bindir}/git ${stagedir}${prefix}/libexec/git-core/git

    # cleanup perl install
    ${__rm} -rf ${stagedir}${prefix}/${_libdir}/perl5/5.*
    ${__rm} -rf ${stagedir}${prefix}/${_libdir}/perl5/site_perl/*/*solaris
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/perl5/site_perl/*/Error.pm

    # Install completion support
    ${__install} -Dp -m0644 contrib/completion/git-completion.bash \
	${stagedir}${prefix}/${_datadir}/git-core/contrib/completion/git-completion.bash
    ${__install} -Dp -m0644 contrib/completion/git-prompt.sh \
	${stagedir}${prefix}/${_datadir}/git-core/contrib/completion/git-prompt.sh
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
