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
version=1.5.3.4
pkgver=2
source[0]=$topdir-$version.tar.bz2
source[1]=$topdir-manpages-$version.tar.bz2
# If there are no patches, simply comment this
patch[0]=git-1.5.3.4-symlinks.patch

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions

# Global settings
export topinstalldir=/usr/sbware
export prefix=$topinstalldir

reg prep
prep()
{
    generic_prep
    setdir source
    perl -i -pe 's;ginstall;/usr/local/bin/install;g' Makefile
    perl -i -pe 's;gtar;/usr/local/bin/tar;g' Makefile
    sed -e '/Define NO_CURL/ s/.*/NO_CURL=Yes/' Makefile > Makefile.1
    mv Makefile.1 Makefile
    sed -e '/PERL_PATH =/ s;.*;PERL_PATH=/opt/csw/bin/perl;' Makefile > Makefile.1
    mv Makefile.1 Makefile
    sed -e '/Define NO_EXPAT/ s/.*/NO_EXPAT=Yes/' Makefile > Makefile.1
    mv Makefile.1 Makefile
#    sed -e '/Define NO_PERL_MAKEMAKER/ s/.*/NO_PERL_MAKEMAKER=Yes/' Makefile.1 > Makefile
#    mv Makefile.1 Makefile
    sed -e '/Define NO_TCLTK/ s/.*/NO_TCLTK=Yes/' Makefile > Makefile.1
    mv Makefile.1 Makefile
    sed -e '/^LDFLAGS/ s;.*;LDFLAGS = -L/usr/sbware/lib -R/usr/sbware/lib;' Makefile > Makefile.1
    mv Makefile.1 Makefile
    sed -e "/^prefix =/ s;.*;prefix = $prefix;" Makefile > Makefile.1
    mv Makefile.1 Makefile
#    sed -e '/Define V=/ s/.*/V=1/' Makefile > Makefile.1
#    mv Makefile.1 Makefile
}

reg build
build()
{
    setdir source
    $MAKE_PROG
#    cd perl
#    perl Makefile.PL PREFIX="${stagedir}${prefix}" INSTALLDIRS="vendor"
}

reg install
install()
{
    generic_install DESTDIR
    mkdir -p ${stagedir}${prefix}/${_mandir}
    setdir ${stagedir}${prefix}/${_mandir}
    $TAR -xvjf ${srcfiles}/${source[1]}
    # Hopeless, absolutely hopeless :(
    setdir ${stagedir}${prefix}/${_libdir}/perl5/site_perl
    mkdir -p ${stagedir}/opt/csw/lib/perl/site_perl
    mv * ${stagedir}/opt/csw/lib/perl/site_perl
    setdir ${stagedir}${prefix}/${_libdir}
    rm -rf perl*
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
