#!/bin/bash
# qihoo_360t7 设备构建配置
# 基于 ImmortalWrt 官方 openwrt-25.12 分支的正式发布版 25.12.2 的 ImageBuilder

# 主机名（首次启动注入 /etc/uci-defaults/99-custom.sh）
export hostname="360T7"
# 设备 profile，必须与 ImageBuilder `make info` / profiles.json 中的名称一致
export profile="qihoo_360t7"
# 目标架构路径
export targets="mediatek/filogic"
# CPU 架构
export arch="aarch64_cortex-a53"
# ImmortalWrt 版本（对应源码分支 openwrt-25.12，包格式已从 ipk 切换为 apk）
export version="25.12.2"
# 后台管理 IP 地址
export ip_address="192.168.10.1"
# 子网掩码
export netmask="255.255.255.0"
