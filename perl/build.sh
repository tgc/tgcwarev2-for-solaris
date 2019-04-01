#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=perl
version=5.28.1
pkgver=1
source[0]=http://www.cpan.org/src/5.0/perl-${version}.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
make_check_target="test"
__configure="sh Configure"
[ "$arch" = "sparc" ] && arch_name="sun4-solaris"
[ "$arch" = "i386" ] && arch_name="i86pc-solaris"
configure_args=(-Dcc=gcc -Doptimize='-O2' -Darchname=${arch_name} -Dprefix=$prefix -Dmyhostname=localhost -Dcf_by="Tom G. Christensen" -Dcf_email=swpkg@jupiterrise.com -Dperladmin=root@localhost -Dinstallprefix=${stagedir}${prefix} -Dman3ext=3pm -Uinstallusrbinperl -Dpager=/usr/bin/more -Dlocincpth=/usr/tgcware/include -Dloclibpth=/usr/tgcware/lib -des -Dinc_version_list='5.16.3 5.16.2')
# Force alignment on SPARC since the configure test can fail:
# https://rt.perl.org/Public/Bug/Display.html?id=133495
[ "$arch" = "sparc" ] && configure_args+=(-Dd_u32align)

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    setdir source
    $__configure "${configure_args[@]}"
    ${__make} LDDLFLAGS="-shared -L$prefix/lib -R$prefix/lib" CLDFLAGS="-L$prefix/lib -R$prefix/lib"
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    generic_install UNKNOWN
    new_perl_lib=${stagedir}${prefix}/lib/perl5/$version
    new_arch_lib=${stagedir}${prefix}/lib/perl5/$version/${arch_name}
    new_perl="${stagedir}${prefix}/bin/perl"
    echo "new_perl = $new_perl"
    echo "new_perl_lib = $new_perl_lib"
    echo "new_arch_lib = $new_arch_lib"
    export LD_LIBRARY_PATH=$new_arch_lib/CORE; export PERL5LIB=$new_perl_lib;
    # fix the packlist and friends
    $new_perl -i -p -e "s|$stagedir||g;" ${stagedir}${prefix}/lib/perl5/$version/${arch_name}/.packlist
    $new_perl -i -p -e "s|$stagedir||g;" ${stagedir}${prefix}/lib/perl5/$version/${arch_name}/Config.pm
    $new_perl -i -p -e "s|$stagedir||g;" ${stagedir}${prefix}/lib/perl5/$version/${arch_name}/Config_heavy.pl
    for i in ${stagedir}${prefix}/bin/*
    do
        if [ ! -z "`head -1 $i|grep perl`" ]; then
            $new_perl -i -p -e "s|$stagedir||g;" $i
        fi
    done
    # Strip shared libraries
    cd $stagedir
    find . -name '*.so' -print | ${__xargs} chmod 755
    do_strip_shared
    cd -

    # Mark compatible the previous versions added to @INC
    compat perl 5.16.2 1 1
    compat perl 5.16.3 1 1
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
