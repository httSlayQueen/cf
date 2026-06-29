#!/bin/bash
#
# 修改 tcpx.sh，使用自定义内核
# 使用方法：运行此脚本，选择【1】“安装 BBR自编译内核”
# 源项目：https://github.com/ylx2016/Linux-NetSpeed.git
#

wget -O tcpx.sh "https://github.com/ylx2016/Linux-NetSpeed/raw/master/tcpx.sh" && chmod +x tcpx.sh

sed -e 's,get_github_asset \"ylx2016/kernel\",get_github_asset \"httSlayQueen/vps-kernel\",g' \
    -i.bak ./tcpx.sh

./tcpx.sh