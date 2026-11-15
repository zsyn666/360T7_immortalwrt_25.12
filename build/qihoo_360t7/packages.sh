#!/bin/bash
# 设备级软件包覆盖（在 config/default_packages.sh 之后 source）
#
# 本固件只保留 ImmortalWrt 25.12.2 官方默认包 + 两个 LuCI 主题，
# 不安装任何第三方插件。
# 默认 manifest 已自带：luci + luci-i18n-*-zh-cn 中文界面、dnsmasq-full、
# firewall4、ppp / ppp-mod-pppoe、wpad-openssl、odhcp6c / odhcpd、uhttpd，
# 以及 kmod-nf-flow / kmod-nft-offload / kmod-nft-fullcone（官方 flow offloading
# 硬件加速，默认即生效，无需 LuCI 里的 Turbo ACC 页面）。
# device profile 会自动附带 kmod-mt7915e / kmod-mt7981-firmware / mt7981-wo-firmware。
#
# 注意：25.12 起包格式为 .apk，不要再引入任何 .ipk 或第三方源。

# 官方最精简 LuCI 主题（保留作为可回退选项）
PACKAGES="$PACKAGES luci-theme-bootstrap"

# 默认主题 7Dollar：不固化 apk 到仓库，由工作流在构建时从上游
# itsmaiGe/luci-theme-7dollar 拉取最新版放进 imagebuilder/packages/，
# ImageBuilder 会自动 apk mkndx 生成索引并纳入安装源。
# 首次启动的主题切换写在 99-custom.sh 里（ImageBuilder 装包用 --no-scripts，
# 主题自带的 post-install 不会执行，必须显式 uci set）。
PACKAGES="$PACKAGES luci-theme-7dollar"
