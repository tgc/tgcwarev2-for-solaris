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
topdir=perl
version=5.8.8
pkgver=1
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_BASE}/scripts/buildpkg.functions
 
# Global settings
make_check_target="test"
__configure="sh Configure"
arch_name="sun4-solaris"
configure_args="-Dcc='gcc' -Darchname=${arch_name} -Dprefix=$prefix -Dmyhostname=localhost -Dcf_by='Tom G. Christensen' -Dcf_email='swpkg@jupiterrise.com' -Dperladmin=root@localhost -Dinstallprefix=${stagedir}${prefix} -Dman3ext=3pm -Uinstallusrbinperl -Dpager='/usr/bin/more' -Dlocincpth='/usr/tgcware/include' -Dloclibpth='/usr/tgcware/lib' -des"

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    setdir source
    $__configure -Dcc='gcc' -Darchname=${arch_name} -Dprefix=$prefix -Dmyhostname=localhost -Dcf_by='Tom G. Christensen' -Dcf_email='swpkg@jupiterrise.com' -Dperladmin=root@localhost -Dinstallprefix=${stagedir}${prefix} -Dman3ext=3pm -Uinstallusrbinperl -Dpager='/usr/bin/more' -Dlocincpth='/usr/tgcware/include' -Dloclibpth='/usr/tgcware/lib' -des
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
    new_perl_lib=${stagedir}${prefix}/lib/$version
    new_arch_lib=${stagedir}${prefix}/lib/$version/${arch_name}
    new_perl_flags="export LD_LIBRARY_PATH=$new_arch_lib/CORE; export PERL5LIB=$new_perl_lib;"
    new_perl="${stagedir}${prefix}/bin/perl"
    echo "new_perl = $new_perl"
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
