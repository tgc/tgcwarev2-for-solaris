#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=git
version=2.16.6
pkgver=2
source[0]=https://www.kernel.org/pub/software/scm/git/$topdir-$version.tar.gz
source[1]=https://www.kernel.org/pub/software/scm/git/$topdir-manpages-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=git-1.8.1.5-inet_addrstrlen.patch
patch[1]=git-2.11.0-stdint_h.patch
patch[2]=git-2.14.1-fix-t5545.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
nosv=$(printf "5%02d" ${gnu_os_ver##*.})
if [ $nosv -ge 507 ]; then # Solaris >= 7
    # fails to distinguish file vs. dir
    GIT_SKIP_TESTS="t1308.23"
fi
if [ $nosv -lt 509 ]; then # Solaris < 9
    # cat-file --textconv is buggy, output is truncated
    GIT_SKIP_TESTS="$GIT_SKIP_TESTS t8010.8 t8010.9"
fi
if [ $nosv -eq 507 ]; then # Solaris = 7
    # SIGPIPE issues
    GIT_SKIP_TESTS="$GIT_SKIP_TESTS t0005.4 t0005.5"
    GIT_SKIP_TESTS="$GIT_SKIP_TESTS t0021.6 t0021.9"
    GIT_SKIP_TESTS="$GIT_SKIP_TESTS t5571.11"
    GIT_SKIP_TESTS="$GIT_SKIP_TESTS t5801.24 t5801.25 t5801.27"
    # TZ=UTC returns GMT instead of UTC
    GIT_SKIP_TESTS="$GIT_SKIP_TESTS t0006.25"
    # fatal: cannot lock ref 'HEAD': Unable to create 'git-2.14.2/t/trash directory.t7600-merge/.git/HEAD.lock': File exists.
    GIT_SKIP_TESTS="$GIT_SKIP_TESTS t7600.56"
fi
export GIT_SKIP_TESTS
no_configure=1
__configure="make"
configure_args=
make_check_target="test"

reg prep
prep()
{
    generic_prep
    setdir source
    cat << EOF > config.mak
V=1
CC=gcc
SHELL=/usr/tgcware/bin/bash
PERL_PATH=$prefix/bin/perl
SHELL_PATH=$prefix/bin/bash
ICONVDIR=$prefix
SANE_TOOL_PATH=/usr/tgcware/gnu:/usr/xpg6/bin:/usr/xpg4/bin
NO_INSTALL_HARDLINKS=YesPlease
BASIC_CFLAGS += -I/usr/tgcware/include
BASIC_LDFLAGS += -L/usr/tgcware/lib -Wl,-R,/usr/tgcware/lib
NEEDS_LIBICONV = YesPlease
NO_PYTHON = YesPlease
INSTALL = /usr/tgcware/bin/ginstall
TAR = /usr/tgcware/bin/gtar
prefix=$prefix
# It takes forever to run SVN tests
NO_SVN_TESTS = YesPlease
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
