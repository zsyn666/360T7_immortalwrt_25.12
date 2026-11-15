#!/bin/bash
# 全局软件包（所有设备共用）
#
# 本项目只构建 qihoo_360t7，且只保留 ImmortalWrt 25.12.2 官方默认包。
# 官方默认 manifest 已包含 LuCI 中文界面、PPPoE / DHCP / DNS、防火墙、
# WiFi、flow offloading 等全部基础上网功能，因此这里不再叠加任何包，
# 也不再引入 argon 主题等第三方插件。
#
# 保持 PACKAGES 为空即可；ImageBuilder 会按 profile 的默认包列表生成固件。

PACKAGES="$PACKAGES"
