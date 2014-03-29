#!/bin/bash
# This is a buildpkg build.sh script
# build.sh helper functions
. ${BUILDPKG_SCRIPTS}/build.sh.functions
#
###########################################################
# Check the following 4 variables before running the script
topdir=vim
shortver=7.4
version=${shortver}.227
pkgver=1
source[0]=ftp://ftp.vim.org/pub/vim/unix/$topdir-$shortver.tar.bz2
# If there are no patches, simply comment this
# for i in `seq 1 14`; do printf "patch[$i]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.%03d\n" $i;done
patch[0]=   # buildpkg does not handle sparse patch array
patch[1]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.001
patch[2]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.002
patch[3]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.003
patch[4]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.004
patch[5]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.005
patch[6]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.006
patch[7]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.007
patch[8]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.008
patch[9]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.009
patch[10]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.010
patch[11]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.011
patch[12]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.012
patch[13]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.013
patch[14]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.014
patch[15]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.015
patch[16]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.016
patch[17]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.017
patch[18]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.018
patch[19]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.019
patch[20]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.020
patch[21]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.021
patch[22]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.022
patch[23]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.023
patch[24]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.024
patch[25]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.025
patch[26]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.026
patch[27]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.027
patch[28]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.028
patch[29]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.029
patch[30]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.030
patch[31]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.031
patch[32]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.032
patch[33]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.033
patch[34]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.034
patch[35]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.035
patch[36]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.036
patch[37]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.037
patch[38]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.038
patch[39]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.039
patch[40]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.040
patch[41]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.041
patch[42]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.042
patch[43]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.043
patch[44]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.044
patch[45]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.045
patch[46]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.046
patch[47]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.047
patch[48]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.048
patch[49]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.049
patch[50]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.050
patch[51]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.051
patch[52]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.052
patch[53]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.053
patch[54]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.054
patch[55]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.055
patch[56]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.056
patch[57]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.057
patch[58]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.058
patch[59]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.059
patch[60]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.060
patch[61]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.061
patch[62]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.062
patch[63]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.063
patch[64]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.064
patch[65]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.065
patch[66]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.066
patch[67]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.067
patch[68]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.068
patch[69]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.069
patch[70]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.070
patch[71]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.071
patch[72]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.072
patch[73]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.073
patch[74]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.074
patch[75]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.075
patch[76]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.076
patch[77]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.077
patch[78]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.078
patch[79]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.079
patch[80]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.080
patch[81]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.081
patch[82]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.082
patch[83]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.083
patch[84]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.084
patch[85]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.085
patch[86]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.086
patch[87]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.087
patch[88]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.088
patch[89]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.089
patch[90]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.090
patch[91]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.091
patch[92]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.092
patch[93]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.093
patch[94]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.094
patch[95]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.095
patch[96]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.096
patch[97]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.097
patch[98]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.098
patch[99]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.099
patch[100]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.100
patch[101]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.101
patch[102]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.102
patch[103]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.103
patch[104]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.104
patch[105]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.105
patch[106]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.106
patch[107]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.107
patch[108]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.108
patch[109]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.109
patch[110]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.110
patch[111]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.111
patch[112]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.112
patch[113]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.113
patch[114]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.114
patch[115]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.115
patch[116]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.116
patch[117]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.117
patch[118]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.118
patch[119]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.119
patch[120]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.120
patch[121]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.121
patch[122]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.122
patch[123]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.123
patch[124]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.124
patch[125]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.125
patch[126]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.126
patch[127]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.127
patch[128]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.128
patch[129]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.129
patch[130]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.130
patch[131]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.131
patch[132]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.132
patch[133]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.133
patch[134]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.134
patch[135]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.135
patch[136]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.136
patch[137]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.137
patch[138]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.138
patch[139]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.139
patch[140]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.140
patch[141]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.141
patch[142]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.142
patch[143]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.143
patch[144]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.144
patch[145]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.145
patch[146]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.146
patch[147]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.147
patch[148]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.148
patch[149]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.149
patch[150]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.150
patch[151]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.151
patch[152]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.152
patch[153]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.153
patch[154]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.154
patch[155]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.155
patch[156]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.156
patch[157]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.157
patch[158]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.158
patch[159]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.159
patch[160]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.160
patch[161]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.161
patch[162]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.162
patch[163]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.163
patch[164]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.164
patch[165]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.165
patch[166]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.166
patch[167]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.167
patch[168]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.168
patch[169]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.169
patch[170]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.170
patch[171]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.171
patch[172]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.172
patch[173]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.173
patch[174]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.174
patch[175]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.175
patch[176]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.176
patch[177]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.177
patch[178]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.178
patch[179]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.179
patch[180]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.180
patch[181]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.181
patch[182]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.182
patch[183]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.183
patch[184]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.184
patch[185]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.185
patch[186]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.186
patch[187]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.187
patch[188]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.188
patch[189]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.189
patch[190]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.190
patch[191]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.191
patch[192]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.192
patch[193]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.193
patch[194]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.194
patch[195]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.195
patch[196]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.196
patch[197]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.197
patch[198]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.198
patch[199]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.199
patch[200]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.200
patch[201]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.201
patch[202]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.202
patch[203]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.203
patch[204]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.204
patch[205]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.205
patch[206]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.206
patch[207]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.207
patch[208]= #ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.208
patch[209]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.209
patch[210]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.210
patch[211]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.211
patch[212]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.212
patch[213]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.213
patch[214]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.214
patch[215]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.215
patch[216]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.216
patch[217]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.217
patch[218]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.218
patch[219]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.219
patch[220]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.220
patch[221]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.221
patch[222]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.222
patch[223]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.223
patch[224]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.224
patch[225]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.225
patch[226]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.226
patch[227]=ftp://ftp.vim.org/pub/vim/patches/7.4/7.4.227

# Source function library
. ${BUILDPKG_SCRIPTS}/buildpkg.functions

# Global settings
export CPPFLAGS="-I/usr/tgcware/include"
export LDFLAGS="-L$prefix/lib -R$prefix/lib"
basic_args=(--prefix=$prefix --without-local-dir --with-features=huge --enable-multibyte --disable-perlinterp --disable-pythoninterp --disable-tclinterp --with-compiledby="<swpkg@jupiterrise.com>" --disable-netbeans)
# Do not let scripts add a dependency on perl
ignore_deps="TGCperl"
# We need to override these
topsrcdir=vim74
patch_prefix="-p0"

reg prep
prep()
{
    generic_prep
}

reg build
build()
{
    # First build a gui version
    configure_args=("${basic_args[@]}" --enable-gui=motif)
    generic_build
    # Save the gui binary for later
    setdir source
    ${__cp} src/vim src/gvim
    setdir source
    ${__make} clean
    # Build without gui
    configure_args=("${basic_args[@]}" --enable-gui=no --with-x=no)
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
    configure_args=("${basic_args[@]}" --enable-gui=motif)
    generic_install DESTDIR
    setdir source
    ${__cp} src/gvim ${stagedir}${prefix}/${_bindir}
    setdir ${stagedir}${prefix}/${_bindir}
    ${__ln} -s gvim gvimdiff
    ${__ln} -s gvim gview
    setdir ${stagedir}${prefix}/${_mandir}/man1
    ${__ln} -s vim.1 gvim.1
    ${__ln} -s vim.1 gview.1
    ${__ln} -s vimdiff.1 gvimdiff.1
    custom_install=1
    generic_install DESTDIR
    doc README.txt
    #setdir ${stagedir}${prefix}/${_sharedir}/vim/vim71/lang/
    #${__mv} "menu_chinese(gb)_gb.936.vim" "menu_chinese_gb__gb.936.vim"
    #${__mv} "menu_chinese(taiwan)_taiwan.950.vim" "menu_chinese_taiwan__taiwan.950.vim"
    ${__rm} -rf ${stagedir}${prefix}/${_mandir}/{fr,it,pl,ru,ja}*
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
