#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=prngd
version=0.9.29
pkgver=2
source[0]=$topdir-$version.tar.gz
# If there are no patches, simply comment this
#patch[0]=

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
no_configure=1
CC=gcc
syslibs="-lsocket -lnsl"
cflags_os="-O2 -DSOLARIS -D__EXTENSIONS__"

__configure="make"
configure_args="CC=$CC CFLAGS=\\\"$cflags_os\\\" SYSLIBS=\\\"$syslibs\\\" DEFS=\\\"-DRANDSAVENAME=\\\"${prefix}/${_sysconfdir}/prngd/prngd-seed\\\" -DCONFIGFILE=\\\"${prefix}/${_sysconfdir}/prngd/prngd.conf\\\"\\\""

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    setdir source
    ${__make} CC=$CC CFLAGS="$cflags_os" SYSLIBS="$syslibs" DEFS="-DRANDSAVENAME=\\\"${prefix}/${_sysconfdir}/prngd/prngd-seed\\\" -DCONFIGFILE=\\\"${prefix}/${_sysconfdir}/prngd/prngd.conf\\\""
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    clean stage
    setdir source
    ${__mkdir} -p ${stagedir}/${_sysconfdir}/init.d
    ${__mkdir} -p ${stagedir}/${_sysconfdir}/rc0.d
    ${__mkdir} -p ${stagedir}/${_sysconfdir}/rc1.d
    ${__mkdir} -p ${stagedir}/${_sysconfdir}/rcS.d
    ${__mkdir} -p ${stagedir}/${_sysconfdir}/rc2.d
    ${__mkdir} -p ${stagedir}${prefix}/${_sbindir}
    ${__mkdir} -p ${stagedir}${prefix}/${_sysconfdir}/prngd
    ${__mkdir} -p ${stagedir}${prefix}/${_mandir}/man1
    ${__cp} prngd ${stagedir}${prefix}/${_sbindir}
    ${__cp} prngd.man ${stagedir}${prefix}/${_mandir}/man1/prngd.1
    chmod 744 ${stagedir}${prefix}/${_sbindir}/prngd
    chmod 644 ${stagedir}${prefix}/${_mandir}/man1/*
    echo "Please fill me up!" > ${stagedir}${prefix}/${_sysconfdir}/prngd/prngd-seed

    # Install entropy gathering script
    ${__cp} contrib/Solaris-2.6/prngd.conf.solaris-26 ${stagedir}${prefix}/${_sysconfdir}/prngd/prngd.conf
    [ "$_os" = "sunos57" ] && ${__cp} contrib/Solaris-7/prngd.conf.solaris-7 ${stagedir}${prefix}/${_sysconfdir}/prngd/prngd.conf

    # Install initscript
    ${__cp} $metadir/prngd.init ${stagedir}/${_sysconfdir}/init.d/tgc_prngd
    chmod 755 ${stagedir}/${_sysconfdir}/init.d/tgc_prngd
    (setdir ${stagedir}/${_sysconfdir}/rc0.d; ${__ln} -sf ../init.d/tgc_prngd K05tgc_prngd)
    (setdir ${stagedir}/${_sysconfdir}/rc1.d; ${__ln} -sf ../init.d/tgc_prngd K05tgc_prngd)
    (setdir ${stagedir}/${_sysconfdir}/rcS.d; ${__ln} -sf ../init.d/tgc_prngd K05tgc_prngd)
    (setdir ${stagedir}/${_sysconfdir}/rc2.d; ${__ln} -sf ../init.d/tgc_prngd S95tgc_prngd)

    # Adjust prngd path in initscript
    ${__gsed} -i "/^PRNGD_BIN/s|=.*|=${prefix}/${_sbindir}/prngd|" ${stagedir}/${_sysconfdir}/init.d/tgc_prngd

    doc 00DESIGN 00README 00README.gatherers ChangeLog

    custom_install=1
    generic_install
}

reg pack
pack()
{
    lprefix=${prefix#/*}
    topinstalldir="/"
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
