#!/bin/sh
# 首次启动脚本：复制到固件 /etc/uci-defaults/99-custom.sh，仅执行一次后由系统清理
# 工作流会在构建阶段用 config.sh 里的 hostname / ip_address / netmask 覆盖下面三个变量

# 基础变量（会被工作流 sed 注入）
hostname="360T7"
ip_address="192.168.10.1"
netmask="255.255.255.0"

# 设置主机名
uci set system.@system[0].hostname="$hostname"
# 设置 LAN 管理地址与子网掩码
uci set network.lan.ipaddr="$ip_address"
uci set network.lan.netmask="$netmask"
# 允许所有网口连接 SSH
uci set dropbear.@dropbear[0].Interface=''
# 固定使用官方精简主题
uci set luci.main.mediaurlbase='/luci-static/bootstrap'
uci commit

# 编译作者信息：写入 /etc/openwrt_release 的 DISTRIB_DESCRIPTION
# 25.12 的该文件使用双引号，故同时兼容单/双引号写法
sed -i -E "s|^(DISTRIB_DESCRIPTION=).*|\1\"By zsyn666\"|" /etc/openwrt_release

exit 0
