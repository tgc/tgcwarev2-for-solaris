#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=git
version=1.7.0.5
pkgver=1
source[0]=$topdir-$version.tar.bz2
source[1]=$topdir-manpages-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=git-1.5.5.1-socklen_t.patch
patch[1]=git-1.7.0.5-symlinks.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings

export ICONVDIR=$prefix
export PERL_PATH=$prefix/bin/perl
export SHELL_PATH=$prefix/bin/bash
no_configure=1
__configure="make"
configure_args=""
# HACK: -e must be last or echo will think it's an argument
__make="/usr/tgcware/bin/make -e"
make_build_target="V=1"
make_check_target="test"

reg prep
prep()
{
    generic_prep
    setdir source
#    mv Makefile.1 Makefile
##    sed -e '/Define NO_PERL_MAKEMAKER/ s/.*/NO_PERL_MAKEMAKER=Yes/' Makefile.1 > Makefile
##    mv Makefile.1 Makefile
    # Solaris 2.6
    cat <<EOF> config.mak
NO_CURL=YesPlease
NO_EXPAT=YesPlease
NO_TCLTK=YesPlease
BASIC_CFLAGS += -I/usr/tgcware/include
BASIC_LDFLAGS += -L/usr/tgcware/lib -Wl,-R,/usr/tgcware/lib
NEEDS_LIBICONV = YesPlease
NO_UNSETENV = YesPlease
NO_SETENV = YesPlease
NO_C99_FORMAT = YesPlease
NO_STRTOUMAX = YesPlease
NO_D_TYPE_IN_DIRENT = YesPlease
NO_SOCKADDR_STORAGE = YesPlease
NO_STRCASESTR = YesPlease
NO_STRLCPY = YesPlease
NO_STRTOUMAX = YesPlease
NO_IPV6 = YesPlease
NO_SOCKLEN_T = YesPlease
NO_HSTRERROR = YesPlease
NO_PYTHON = YesPlease
EXTLIBS += -lresolv
TAR = /usr/tgcware/bin/tar
INSTALL = /usr/tgcware/bin/install
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
    setdir ${stagedir}${prefix}/${_mandir}
    ${__tar} -xjf $(get_source_absfilename "${source[1]}")
    doc COPYING Documentation/RelNotes-${version}.txt README

    # fix git symlink
    ${__rm} -f ${stagedir}${prefix}/libexec/git-core/git
    ${__ln} -s ${prefix}/${_bindir}/git ${stagedir}${prefix}/libexec/git-core/git

    # cleanup perl install
    ${__rm} -rf ${stagedir}${prefix}/${_libdir}/perl5/5.*
    ${__rm} -rf ${stagedir}${prefix}/${_libdir}/perl5/site_perl/*/*solaris
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/perl5/site_perl/*/Error.pm

    mkdir -p ${stagedir}${prefix}/${_mandir}
    setdir ${stagedir}${prefix}/${_mandir}
    ${__tar} -xvjf ${srcfiles}/${source[1]}
    # Hopeless, absolutely hopeless :(
    #setdir ${stagedir}${prefix}/${_libdir}/perl5/site_perl
    #mkdir -p ${stagedir}/opt/csw/lib/perl/site_perl
    #mv * ${stagedir}/opt/csw/lib/perl/site_perl
    #setdir ${stagedir}${prefix}/${_libdir}
    #rm -rf perl*
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
