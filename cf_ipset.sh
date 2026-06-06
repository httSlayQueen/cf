#!/bin/bash
####################
# 生成cf的ipset，并应用到ufw
# 默认功能：仅允许CF的IP访问TCP 443端口
# 参考：https://www.5dzone.com/posts/ufw-ipset%E6%89%93%E9%80%A0%E9%AB%98%E6%95%88ip%E9%BB%91%E5%90%8D%E5%8D%95%E8%AE%BF%E9%97%AE%E5%B0%81%E9%94%81%E5%88%A9%E5%99%A8.html
####################
DOWNLOAD_URL="https://github.com/Loyalsoldier/geoip/raw/refs/heads/release/text/cloudflare.txt"
WORK_DIR="/home/cf_list"
LIST="$WORK_DIR/cf.txt"
LIST_V4="$WORK_DIR/cfv4.txt"
LIST_V6="$WORK_DIR/cfv6.txt"
CONF_V4="$WORK_DIR/cfv4.conf"
CONF_V6="$WORK_DIR/cfv6.conf"


#初始化目录
if [ -d "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR"/*
fi

if [ ! -d "$WORK_DIR" ]; then
    mkdir -p "$WORK_DIR"
fi

#下载IP列表
wget -q -O "$LIST" "$DOWNLOAD_URL"
DOWNLOAD_RESULT=$?

#检查下载结果
if [ "$DOWNLOAD_RESULT" -ne 0 ]; then
    echo "下载失败：$DOWNLOAD_URL"
    exit 1
elif [ ! -s "$LIST" ]; then
    echo "下载了空文件：$DOWNLOAD_URL"
    exit 1
else
    echo "CFIP列表下载成功"
fi

#拆分v4 v6
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?' "$LIST" > "$LIST_V4"
grep -Eio '([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}(/[0-9]{1,3})?' "$LIST" > "$LIST_V6"

#创建ipset
if ! ipset list cfv4 &>/dev/null; then
    ipset create cfv4 hash:net family inet hashsize 4096 maxelem 1000000
else
    ##已存在，清空
    ipset flush cfv4
fi
if ! ipset list cfv6 &>/dev/null; then
    ipset create cfv6 hash:net family inet6 hashsize 4096 maxelem 1000000
else
    ##已存在，清空
    ipset flush cfv6
fi

#添加到ipset
if [ -s "$LIST_V4" ]; then
    sed 's/^/add cfv4 /' "$LIST_V4" | ipset restore -!
    ##单独保存IPv4规则
    ipset save cfv4 -f "$CONF_V4"
    echo "ipset已保存: cfv4"
fi
if [ -s "$LIST_V6" ]; then
    sed 's/^/add cfv6 /' "$LIST_V6" | ipset restore -!
    ##单独保存IPv6规则
    ipset save cfv6 -f "$CONF_V6"
    echo "ipset已保存: cfv6"
fi

#ufw设置，如果要新增，记得先到对应文件删除，否则if逻辑不通不能添加
if [ -s "$CONF_V4" ]; then
    if ! grep -qx ".*-A ufw-before-input -p tcp --dport 443 -m set --match-set cfv4 src -j ACCEPT" /etc/ufw/before.rules; then
        sed -i '/^COMMIT$/i -A ufw-before-input -p tcp --dport 443 -m set --match-set cfv4 src -j ACCEPT' /etc/ufw/before.rules
        echo -e "IPv4规则已成功集成到ufw"
    fi
fi
if [ -s "$CONF_V6" ]; then
    if ! grep -qx ".*-A ufw6-before-input -p tcp --dport 443 -m set --match-set cfv6 src -j ACCEPT" /etc/ufw/before6.rules; then
        sed -i '/^COMMIT$/i -A ufw6-before-input -p tcp --dport 443 -m set --match-set cfv6 src -j ACCEPT' /etc/ufw/before6.rules
        echo -e "IPv6规则已成功集成到ufw"
    fi
fi

#写入启动脚本，并添加执行权限
TAB="    "
TEXT_V4="${TAB}ipset restore -f ${CONF_V4}"
TEXT_V6="${TAB}ipset restore -f ${CONF_V6}"
if ! grep -q "$TEXT_V4" /etc/ufw/before.init; then
    sed -i.bak "/^[^#]*start)/a\\$TEXT_V4" /etc/ufw/before.init
    sed -i.bak "/^[^#]*start)/a\\$TEXT_V6" /etc/ufw/before.init
    echo -e "ufw启动脚本写入完成"
else
    echo -e "跳过修改ufw启动脚本"
fi
chmod +x /etc/ufw/before.init

ufw reload
iptables -vnL | grep cfv4
ip6tables -vnL | grep cfv6
