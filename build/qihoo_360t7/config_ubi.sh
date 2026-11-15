#!/bin/bash
# qihoo_360t7 UBI 布局构建配置
# 用于已刷过 UBI 布局 U-Boot / 分区表的 360T7（当前设备即为此布局，
# /proc/mtd 里是 "ubi" 分区，rootfs 挂载为 ubifs）。
# 对应 ImageBuilder 官方 profile: qihoo_360t7-ubi

export hostname="360T7"
export profile="qihoo_360t7-ubi"
export targets="mediatek/filogic"
export arch="aarch64_cortex-a53"
export version="25.12.2"
export ip_address="192.168.10.1"
export netmask="255.255.255.0"
# 布局标识，用于 Release tag 区分
export layout="ubi"
