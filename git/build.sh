#!/bin/bash
#
# This is a generic build.sh script
# It can be used nearly unmodified with many packages
# 
# build.sh helper functions
. ${BUILDPKG_BASE}/scripts/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=git
version=1.5.5.1
pkgver=1
source[0]=$topdir-$version.tar.bz2
source[1]=$topdir-manpages-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=git-1.5.3.4-symlinks.patch
patch[1]=git-1.5.5.1-socklen_t.patch
patch[2]=git-1.5.5.1-sunos56.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Global settings

# Helper to tweak makefile defines
set_define()
{
	${__sed} -e "/Define $1/ s/.*/$1=$2/" Makefile > Makefile.1
	mv Makefile.1 Makefile
}

export ICONVDIR=$prefix
export PERL_PATH=$prefix/bin/perl
export SHELL_PATH=$prefix/bin/bash
no_configure=1
make_check_target="test"
__configure="make"
configure_args=""

reg prep
prep()
{
    generic_prep
    setdir source
    perl -i -pe "s;ginstall;${__install};g" Makefile
    perl -i -pe "s;gtar;${__tar};g" Makefile
    for def in NO_CURL NO_EXPAT NO_TCLTK; do
	set_define $def YesPlease
    done

    # Set default buildflags
    sed -e "/^LDFLAGS/ s;.*;LDFLAGS = -L$prefix/lib -R$prefix/lib;" Makefile > Makefile.1
    mv Makefile.1 Makefile
    sed -e "/^CFLAGS/ s;\(.*\);\1 -I$prefix/include;" Makefile > Makefile.1
    mv Makefile.1 Makefile
    sed -e "/^prefix =/ s;.*;prefix = $prefix;" Makefile > Makefile.1
    mv Makefile.1 Makefile

#    sed -e '/Define V=/ s/.*/V=1/' Makefile > Makefile.1
#    mv Makefile.1 Makefile
##    sed -e '/Define NO_PERL_MAKEMAKER/ s/.*/NO_PERL_MAKEMAKER=Yes/' Makefile.1 > Makefile
##    mv Makefile.1 Makefile
}

reg build
build()
{
    generic_build
#    setdir source
#    ${__make}
#    cd perl
#    perl Makefile.PL PREFIX="${stagedir}${prefix}" INSTALLDIRS="vendor"
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
