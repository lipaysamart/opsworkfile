#!/bin/bash
#####################
# author: Ethan
# email: lipaysamart@gmail.com
# Description: set static address.
# example：bash setip.sh
#####################

# 设置静态 IP 配置

set_static_ip() {

NETMASK="255.255.255.0"  # 替换为你的子网掩码
INTERFACE=$(ip -o link show | awk -F ': '  'NR == 2{print $2}')  # 获取网络接口名称
CIDR=$(ip -4  addr show ${INTERFACE} | grep inet | awk '{print $2}') # 获取 CIDR
STATIC_IP=$(echo $CIDR | cut -d '/' -f 1)  # 设置为当前静态 IP 地址
IFS='.' read -r i1 i2 i3 i4 <<< "$STATIC_IP" # 从标准输入读取数据将其分配给变量并使用 '.' 作为字段分隔符, '-r' 禁止反斜杠转义
GATEWAY="$i1.$i2.$i3.1"  # 替换为你的网关地址
DNS_SERVERS="223.6.6.6 1.1.1.1"  # 替换为你的 DNS 服务器地址

# 备份原有配置
echo "备份原有网络配置文件..."
cp /etc/network/interfaces /etc/network/interfaces.bak

# 写入新的静态 IP 配置
echo "更新网络配置文件..."
cat <<EOL | tee /etc/network/interfaces
# 网络配置文件
auto $INTERFACE
iface $INTERFACE inet static
    address $STATIC_IP
    netmask $NETMASK
    gateway $GATEWAY
    dns-nameservers $DNS_SERVERS
EOL

# 重启网络服务
echo "重启网络服务..."
sudo systemctl restart networking

# 验证配置
echo "验证网络配置..."
ip a | grep $INTERFACE

echo "静态 IP 配置已更新完成！"
}

set_static_ip()