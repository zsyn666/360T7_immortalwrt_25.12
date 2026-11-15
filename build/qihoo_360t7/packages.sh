#!/bin/bash
# 设备级软件包覆盖（在 config/default_packages.sh 之后 source）
#
# 本固件只保留 ImmortalWrt 25.12.2 官方默认包 + 一个官方精简主题，
# 不安装任何第三方插件。
# 默认 manifest 已自带：luci + luci-i18n-*-zh-cn 中文界面、dnsmasq-full、
# firewall4、ppp / ppp-mod-pppoe、wpad-openssl、odhcp6c / odhcpd、uhttpd，
# 以及 kmod-nf-flow / kmod-nft-offload / kmod-nft-fullcone（官方 flow offloading
# 硬件加速，默认即生效，无需 LuCI 里的 Turbo ACC 页面）。
# device profile 会自动附带 kmod-mt7915e / kmod-mt7981-firmware / mt7981-wo-firmware。
#
# 注意：25.12 起包格式为 .apk，不要再引入任何 .ipk 或第三方源。

# 官方最精简 LuCI 主题（默认 manifest 已含，此处显式声明便于锁定版本）
PACKAGES="$PACKAGES luci-theme-bootstrap"
