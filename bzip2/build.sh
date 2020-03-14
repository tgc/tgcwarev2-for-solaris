#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=bzip2
version=1.0.8
pkgver=1
source[0]=http://bzip.org/${version}/$topdir-$version.tar.gz
# If there are no patches, simply comment this
patch[0]=bzip2-1.0.8-sane_soname.patch

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
shortroot=1

reg prep
prep()
{
    generic_prep
    # Solaris ld needs -h instead of -soname
    ${__gsed} -i 's/-soname/-h/g' Makefile-libbz2_so
}

reg build
build()
{
    setdir source
    ${__make} -f Makefile-libbz2_so CC="gcc -R$prefix/lib"
    rm -f *.o
    ${__make} -f Makefile LDFLAGS="-R$prefix/lib"
}

reg check
check()
{
    generic_check
}

reg install
install()
{
    generic_install PREFIX

    setdir source
    # Install shared library
    ${__install} -m 755 libbz2.so.${version} ${stagedir}${prefix}/${_libdir}
    ${__ln} -s libbz2.so.${version} ${stagedir}${prefix}/${_libdir}/libbz2.so.1
    ${__ln} -s libbz2.so.1 ${stagedir}${prefix}/${_libdir}/libbz2.so

    # Install dynamically linked bzip2 binary
    ${__install} -m 755 bzip2-shared  ${stagedir}${prefix}/${_bindir}/bzip2
    ${__rm} -f ${stagedir}${prefix}/${_bindir}/b{unzip2,zcat}
    ${__ln} -s bzip2 ${stagedir}${prefix}/${_bindir}/bunzip2
    ${__ln} -s bzip2 ${stagedir}${prefix}/${_bindir}/bzcat

    custom_install=1
    generic_install PREFIX

    doc LICENSE CHANGES README README.COMPILATION.PROBLEMS
    docs_for bzip2-devel manual.html

    ${__mv} ${stagedir}${prefix}/man ${stagedir}${prefix}/share

    compat bzip2 1.0.6 1 2

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
