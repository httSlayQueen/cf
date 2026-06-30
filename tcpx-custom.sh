#!/bin/bash
#
# 修改 tcpx.sh，使用自定义内核
# 使用方法：运行此脚本，选择【1】“安装 BBR自编译内核”
# 源项目：https://github.com/ylx2016/Linux-NetSpeed.git
#

# Github 项目名称
CUSTOM_REPO="httSlayQueen/vps-kernel"

# 下载 tcp.sh
wget -O tcpx.sh "https://github.com/ylx2016/Linux-NetSpeed/raw/master/tcpx.sh" && chmod +x tcpx.sh

# 修改目的地址
sed -e "s,get_github_asset \"ylx2016/kernel\",get_github_asset \"${CUSTOM_REPO}\",g" \
    -e "s,正在向 Github/ylx2016,正在向 Github/${CUSTOM_REPO},g" \
    -i.bak ./tcpx.sh

# 运行
./tcpx.sh
