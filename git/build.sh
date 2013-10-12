#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=git
version=1.8.4.1
pkgver=1
source[0]=http://git-core.googlecode.com/files/$topdir-$version.tar.gz
source[1]=http://git-core.googlecode.com/files/$topdir-manpages-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=git-1.8.1.5-inet_addrstrlen.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings

no_configure=1
__configure="make"
configure_args=
# HACK: -e must be last or echo will think it's an argument
#__make="/usr/tgcware/bin/make -e"
make_build_target="V=1"
make_check_target="test"

reg prep
prep()
{
    generic_prep
    setdir source
    cat <<EOF> config.mak
CC=gcc
PERL_PATH=$prefix/bin/perl
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
    doc COPYING Documentation/RelNotes/${version}.txt README

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
