#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=openssh
version=9.9p1
pkgver=2
source[0]=https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=0007-Fix-authopt-test-on-platforms-without-IPv6-support.patch
patch[1]=openssh-9.9-fixes.patch # stable branch post release fixes
patch[2]=0001-fix-uint64_t-types-reported-by-Tom-G.-Christensen.patch
patch[3]=old-autoconf.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

if [ "$_os" = "sunos57" ]; then
    patch[4]=0001-regress-login-timeout.sh-increase-timeouts.patch
    patch[5]=0001-Revert-simplify-sshkey_prekey_alloc-always-use-mmap.patch
fi

# Global settings
export LDFLAGS="-R$prefix/lib -L$prefix/lib"
export CPPFLAGS="-I$prefix/include"
export CC="gcc"
make_check_target="tests"

configure_args=(--prefix=$prefix --mandir=$prefix/$_mandir --sysconfdir=$prefix/${_sysconfdir}/ssh --datadir=$prefix/${_sharedir}/openssh --with-default-path=/usr/bin:$prefix/${_bindir} --with-mantype=man --with-pam --with-privsep-user=sshd --with-privsep-path=/var/empty/sshd --with-superuser-path=/usr/bin:/usr/sbin:$prefix/$_bindir:$prefix/$_sbindir --with-lastlog=/var/adm/lastlog --without-zlib-version-check --enable-dsa-keys)

reg prep
prep()
{
    generic_prep
    setdir source
    autoreconf
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
    clean stage
    setdir source
    ${__make} DESTDIR=$stagedir install-nokeys

    ${__mkdir} -p ${stagedir}/${_sysconfdir}/init.d
    ${__mkdir} -p ${stagedir}/${_sysconfdir}/rc0.d
    ${__mkdir} -p ${stagedir}/${_sysconfdir}/rc1.d
    ${__mkdir} -p ${stagedir}/${_sysconfdir}/rc2.d
    ${__mkdir} -p ${stagedir}/${_sysconfdir}/rcS.d
    ${__mkdir} -p ${stagedir}/var/empty/sshd

    # Install initscript
    ${__cp} $srcdir/sshd.init ${stagedir}/${_sysconfdir}/init.d/tgc_sshd
    chmod 755 ${stagedir}/${_sysconfdir}/init.d/tgc_sshd
    (setdir ${stagedir}/${_sysconfdir}/rc0.d; ${__ln} -sf ../init.d/tgc_sshd K02tgc_sshd)
    (setdir ${stagedir}/${_sysconfdir}/rc1.d; ${__ln} -sf ../init.d/tgc_sshd K02tgc_sshd)
    (setdir ${stagedir}/${_sysconfdir}/rcS.d; ${__ln} -sf ../init.d/tgc_sshd K02tgc_sshd)
    (setdir ${stagedir}/${_sysconfdir}/rc2.d; ${__ln} -sf ../init.d/tgc_sshd S98tgc_sshd)

    custom_install=1
    generic_install
    doc CREDITS ChangeLog INSTALL LICENCE OVERVIEW README* PROTOCOL* TODO

    setdir ${stagedir}${prefix}/${_sysconfdir}/ssh
    for i in *; do ${__mv} $i $i.default; done
}

reg pack
pack()
{
    lprefix=${prefix#/*}
    topinstalldir=/
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
