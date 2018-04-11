#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=python
version=2.7.14
pkgver=1
source[0]=https://www.python.org/ftp/python/$version/Python-$version.tar.xz
# If there are no patches, simply comment this
patch[0]=python-2.7.9-tgcware.patch
patch[1]=python-2.7.9-multiprocessing-without-urandom.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I$prefix/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"

configure_args+=(--with-system-expat --enable-shared)
make_check_target=test

# Reduce e.g. 2.7.9 to 2.7
pydotver=${version%.*}
dynload_dir=$_libdir/python${pydotver}/lib-dynload
site_packages=$_libdir/python${pydotver}/site-packages
pylibdir=$_libdir/python${pydotver}
topsrcdir=Python-${version}

reg prep
prep()
{
    generic_prep
    setdir source
    echo "crypt cryptmodule.c" >> Modules/Setup.local
    rm -f Tools/pynche/*.pyw
    ${__gsed} -i '/INSTALL_SHARED/ s/555/755/' Makefile*
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
    setdir source
    # This borrows heavily from CentOS rpm packages
    echo '#!/bin/sh' > ${stagedir}${prefix}/$_bindir/pynche${pydotver}
    echo 'exec `python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(plat_specific = True))"`/pynche/pynche' >> ${stagedir}${prefix}/$_bindir/pynche${pydotver}
    cp -pr Tools/pynche ${stagedir}${prefix}/$site_packages
    ${__install} -p -m755 Tools/i18n/pygettext.py ${stagedir}${prefix}/$_bindir/pygettext${pydotver}.py
    ${__install} -p -m755 Tools/i18n/msgfmt.py ${stagedir}${prefix}/$_bindir/msgfmt${pydotver}.py
    ${__install} -p -m755 -d ${stagedir}${prefix}/$pylibdir/Tools/scripts
    ${__install} -p -m755 Tools/README ${stagedir}${prefix}/$pylibdir/Tools
    ${__install} -p -m755 Tools/scripts/*py ${stagedir}${prefix}/$pylibdir/Tools/scripts
    ${__mv} ${stagedir}${prefix}/${_bindir}/2to3 ${stagedir}${prefix}/${_bindir}/2to3-${pydotver}
    ${__mv} ${stagedir}${prefix}/${_bindir}/idle ${stagedir}${prefix}/${_bindir}/idle${pydotver}
    ${__mv} ${stagedir}${prefix}/${_bindir}/pydoc ${stagedir}${prefix}/${_bindir}/pydoc${pydotver}
    ${__mv} ${stagedir}${prefix}/${_bindir}/smtpd.py ${stagedir}${prefix}/${_bindir}/smtpd${pydotver}.py
    ${__rm} -f ${stagedir}${prefix}/${_bindir}/python{,-config}
    ${__rm} -f ${stagedir}${prefix}/${_bindir}/python2{,-config}
    ${__rm} -f ${stagedir}${prefix}/${pylibdir}/LICENSE.txt
    ${__rm} -f ${stagedir}${prefix}/${_mandir}/man1/python{,2}.1
    ${__rm} -f ${stagedir}${prefix}/${_libdir}/pkgconfig/python{,2}.pc
    docs_for python27 LICENSE README
    docs_for python27-libs LICENSE README

    for ver in 2.7.9 2.7.10 2.7.11 2.7.12 2.7.13
    do
        compat python27 $ver 1 1
        compat python27-libs $ver 1 1
        compat python27-tkinter $ver 1 1
        compat python27-tools $ver 1 1
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
