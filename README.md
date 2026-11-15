# OpenWrt-ImageBuilder（qihoo_360t7 专用）

基于 GitHub Actions + ImmortalWrt 官方 ImageBuilder 的自动化固件构建仓库。

**只构建 `qihoo_360t7`（360 T7）一台设备，只保留官方默认包 + LuCI 主题，不编译、不安装任何第三方插件。**

基础版本：ImmortalWrt **25.12.2**（对应源码分支 [`immortalwrt/immortalwrt @ openwrt-25.12`](https://github.com/immortalwrt/immortalwrt/tree/openwrt-25.12)）。

> ⚠️ 25.12 起包格式从 `.ipk` 切换为 `.apk`，旧版的第三方 ipk 插件链（源码编译、`extra_packages.sh`、`config/extra_packages.json`、包 release 下载）已整体移除。

---

## 一次构建，两种布局同一个 Release

**每次运行同时产出 `qihoo_360t7`（非 UBI / 原厂分区）和 `qihoo_360t7-ubi`（UBI 分区）两套固件，一起发布到同一个 Release。**

两个 profile 都存在于同一份 ImageBuilder 的 `profiles.json` 里，所以工作流只下载、解压一次 ImageBuilder，顺序跑两次 `make image`（`_call_image` 每次都会重建 `TARGET_DIR`，天然隔离）。产物文件名自带 profile 名，不会混淆；`sha256sums` 会加 `-<profile>` 后缀避免同名覆盖。

| 布局 | Profile | 适用设备 | 文件名特征 |
| --- | --- | --- | --- |
| 非 UBI | `qihoo_360t7` | 原厂分区表 / 原厂 U-Boot | `25.12.2-qihoo_360t7-*` |
| UBI | `qihoo_360t7-ubi` | 已刷第三方 UBI 布局 U-Boot | `25.12.2-qihoo_360t7-ubi-*` |

刷机前请按自己设备的分区布局选择，刷错会无法启动。

Release Tag：`25.12-qihoo_360t7`（唯一一个，不再单独发布 `-ubi` 结尾的 Release）。

## LuCI 默认主题：7Dollar

默认主题为 [7Dollar](https://github.com/itsmaiGe/luci-theme-7dollar)，**构建时从上游拉取最新版 apk，不把第三方二进制文件固化进本仓库**：

1. 工作流读取上游 `dist/latest-apk.txt` 得到当前 25.x 适用的 apk 文件名与版本
2. 从该版本的 GitHub Release（失败则回退仓库内 `dist/`）下载到 `imagebuilder/packages/`
3. ImageBuilder 会自动 `apk mkndx` 生成索引，并通过 `--repository packages.adb` 纳入安装源
4. `PACKAGES` 里追加 `luci-theme-7dollar`，`make image` 时装进固件
5. ImageBuilder 以 `--no-scripts` 装包，主题自带的 post-install 不会执行，因此 `99-custom.sh` 在首次启动时显式 `uci set luci.main.mediaurlbase='/luci-static/7dollar'`

官方 `luci-theme-bootstrap` 仍然保留，可在 **系统 → 系统 → 语言和界面 → 主题** 随时切回。

## 仓库结构

```text
OpenWrt-Actions/
├─ .github/workflows/
│  └─ build-openwrt-image.yml          # 唯一的工作流：下载 ImageBuilder → 拉 7Dollar → 双布局打包 → 同一 Release
├─ build/
│  └─ qihoo_360t7/                     # 唯一的设备目录
│     ├─ config.sh                     # 非 UBI 配置（也是公共参数基准）
│     ├─ config_ubi.sh                 # UBI 布局配置（仅 profile / layout 不同）
│     ├─ packages.sh                   # 设备级包（bootstrap + 7Dollar）
│     └─ 99-custom.sh                  # 首次启动脚本（主机名 / LAN IP / 主题 / 作者信息）
└─ config/
   └─ default_packages.sh               # 全局包（留空，使用官方默认包）
```

## 基础上网功能由官方默认包提供

`PACKAGES` 基本留空即可，25.12.2 默认 manifest 实测已自带：

| 类别 | 包 |
| --- | --- |
| Web 后台 | `luci`、`luci-base`、`luci-mod-*`、`luci-theme-bootstrap`、`luci-light`、`uhttpd` |
| 中文界面 | `luci-i18n-base-zh-cn`、`luci-i18n-firewall-zh-cn`、`luci-i18n-package-manager-zh-cn` 等 |
| 拨号 / 地址分配 | `ppp`、`ppp-mod-pppoe`、`dnsmasq-full`、`odhcp6c`、`odhcpd-ipv6only` |
| 防火墙 / NAT | `firewall4`、`nftables-json`、`kmod-nft-*` |
| 硬件加速 | `kmod-nf-flow`、`kmod-nft-offload`、`kmod-nft-fullcone`（官方 flow offloading，**默认生效**） |
| WiFi | `wpad-openssl`、`hostapd-common` |
| 设备驱动 | profile 自动附带 `kmod-mt7915e`、`kmod-mt7981-firmware`、`mt7981-wo-firmware` |

### 关于「Turbo ACC 网络加速」

LuCI 里那个 **Turbo ACC 网络加速设置页是第三方 `luci-app-turboacc` 提供的，25.12 官方源已不包含，本固件也没有**。

但**底层加速能力还在且默认开启**：`kmod-nft-offload` / flowtable / fullcone NAT 属于官方基础网络功能，MT7981 的硬件转发照常工作，无需任何配置、无需任何第三方插件。

## 本固件的定制项

全部集中在 `build/qihoo_360t7/99-custom.sh`（首次启动执行一次后被系统清理）：

- 主机名：`360T7`
- LAN 管理地址：`192.168.10.1` / `255.255.255.0`（可在 Actions 手动触发时用 `ip_address` 覆盖）
- SSH 允许所有网口连接
- LuCI 默认主题：`7Dollar`（可切回 `bootstrap`）
- `/etc/openwrt_release` 的 `DISTRIB_DESCRIPTION` 写为 `By zsyn666`

## 构建流程

工作流：`.github/workflows/build-openwrt-image.yml`（单 job）

1. 读取 `build/qihoo_360t7/config.sh` 的公共参数
2. 从 `https://downloads.immortalwrt.org/releases/25.12.2/targets/mediatek/filogic/` 下载官方 ImageBuilder，并用 `sha256sums` 校验
3. 缓存 ImageBuilder（`actions/cache`，key 含版本号与 sha256）
4. 从 7Dollar 上游拉最新 apk 到 `imagebuilder/packages/`
5. 合并包列表：`config/default_packages.sh`（空）→ `build/qihoo_360t7/packages.sh`
6. 复制并注入 `99-custom.sh`
7. **依次** `make -j$(nproc) image PROFILE="qihoo_360t7" ...` 与 `PROFILE="qihoo_360t7-ubi" ...`，每次归档后清空产物
8. 删除同名旧 Release / Tag（含历史的 `-ubi` 结尾 Release），发布两套固件到同一个 Release

### 触发方式

- **手动**：Actions → `Build OpenWrt Image (qihoo_360t7)` → Run workflow，可选填后台 IP
- **定时**：每周五 UTC 00:00（北京时间周五 08:00）

手动触发时不再需要选布局，两种布局每次都一起产出。

### 产物命名

上传前会去掉前缀 `immortalwrt-` 和文件名里的 `mediatek-filogic-` 段，例如：

```text
25.12.2-qihoo_360t7-squashfs-sysupgrade.itb
25.12.2-qihoo_360t7-initramfs-recovery.itb
25.12.2-qihoo_360t7-bl31-uboot.fip
25.12.2-qihoo_360t7-preloader.bin
25.12.2-qihoo_360t7-ubi-squashfs-sysupgrade.itb
25.12.2-qihoo_360t7-ubi-initramfs-recovery.itb
...
sha256sums-qihoo_360t7
sha256sums-qihoo_360t7-ubi
```

## 如何改版本

编辑 `build/qihoo_360t7/config.sh` 与 `config_ubi.sh` 的 `version`（两处保持一致），例如改成 `25.12.3`。需确认上游存在对应的 ImageBuilder 文件：

```text
https://downloads.immortalwrt.org/releases/<version>/targets/mediatek/filogic/
  immortalwrt-imagebuilder-<version>-mediatek-filogic.Linux-x86_64.tar.zst
```

`profile` 名称可用 ImageBuilder 里的 `make info` 或上游 `profiles.json` 核对，当前为 `qihoo_360t7` 与 `qihoo_360t7-ubi`。

## 如何加回官方包

在 `build/qihoo_360t7/packages.sh` 里追加，例如：

```bash
PACKAGES="$PACKAGES iperf3"
```

只写**官方源里存在**的包名（`.apk` 格式），不要引入第三方 feed 或 `.ipk`。

## 常见问题

| 现象 | 排查 |
| --- | --- |
| ImageBuilder 下载 404 | `config.sh` / `config_ubi.sh` 的 `version` 与上游发布版本号不一致 |
| `sha256sum -c` 失败 | 上游 `sha256sums` 更新，清掉 Actions 缓存后重试 |
| 构建报 PROFILE 不存在 | 用 `make info` 核对 `profile`，注意 360T7 有 `qihoo_360t7` 与 `qihoo_360t7-ubi` 两个 |
| 主题还是 Bootstrap | `99-custom.sh` 的 `mediaurlbase` 未生效，或主题 apk 未装进固件，看构建日志的 `Installing packages...` |
| 7Dollar apk 下载失败 | 上游 Release 无对应 tag，工作流会自动回退到仓库内 `dist/`；若两者都失败检查 `latest-apk.txt` |
| 找不到 Turbo ACC 菜单 | 符合预期，见上文「关于 Turbo ACC 网络加速」 |

## 免责声明

本仓库仅提供自动化构建流程示例。刷机有风险，请确保已了解 360 T7 的刷写与救援方法。
