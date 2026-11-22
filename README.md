# H3C Magic NX30 Pro 固件（ImmortalWrt 24.10 / kernel 6.6）

自用的 H3C Magic NX30 Pro 固件构建仓库：只保留 `.config` + 两个 DIY 脚本，固件由 GitHub Actions 自动编译并发布到 [Releases](../../releases)。

- 源码：[padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6) 分支 `openwrt-24.10-6.6`（联发科闭源 WiFi 驱动）
- 目标配置：`mediatek/filogic`，设备 `h3c_magic-nx30-pro-nmbm`
- 本仓库 fork 自 [jiehuihui/immortalwrt24.10-6.6-cmcc_rax3000m-237](https://github.com/jiehuihui/immortalwrt24.10-6.6-cmcc_rax3000m-237)，已改为 NX30 Pro

## 设备信息

| 项目 | 值 |
|---|---|
| SoC | MediaTek MT7981B（AArch64, cortex-a53） |
| 内存 | 256 MB |
| 闪存 | 128 MB SPI-NAND，UBI 分区 64 MB |
| 无线 | MT7981 内置 2.4G + MT7976 5G（闭源驱动 `mtwifi-cfg`） |
| 后台地址 | http://192.168.6.1 |
| 默认账号 | `root`，密码为空 |

> 刷完后请立刻设置 root 密码，不要把管理界面暴露在 WAN 侧。

## 固件说明

每次构建产出三个文件（在 Release 里下载）：

| 文件 | 用途 |
|---|---|
| `*-squashfs-sysupgrade.bin` | **已在使用 OpenWrt/ImmortalWrt 时升级**，Web 后台「系统 → 备份/升级」直接刷，保留配置可选 |
| `*-squashfs-factory.bin` | **首次刷机 / 救砖**，进 U-Boot 网页恢复界面上传 |
| `*-initramfs-kernel.bin` | 临时启动镜像，只在内存里跑、不写 flash，用于试机或救急 |

### 刷机流程（首次，以你机器上的 U-Boot 版本为准）

1. 路由器断电，网线接 LAN 口，电脑网卡固定为 `192.168.1.2/24`
2. 按住 Reset 键（或 U-Boot 进恢复模式的按键，视你刷的不死 U-Boot 而定）再通电，等指示灯闪烁
3. 浏览器打开 `192.168.1.1`，进入 U-Boot 网页恢复页面，选择 `*-squashfs-factory.bin` 上传
4. 写入完成后设备自动重启，访问 `192.168.6.1`，用 `root` + 空密码登录

> 不建议在未刷不死 U-Boot 的原厂固件上直接刷第三方固件；操作前请先备份原厂分区（Factory/BL2/FIP），刷机有变砖风险，自负。

## 集成的插件

ZeroTier、TurboACC（`turboacc-mtk`）、EQOS（`eqos-mtk`）、WOL、wrtbwmon、ramfree、ttyd、`mtwifi-cfg`、`package-manager`，主题为 Bootstrap。

PassWall 已经评估过并放弃：256MB 内存 + MT7981 跑 xray/sing-box 不划算，装了也是摆设。`.config` 里残留的几条 `CONFIG_PACKAGE_luci-app-passwall_INCLUDE_*` 属于孤儿选项（主包从不启用），没有任何实际影响。

需要增删软件包：改 `.config`（在源码目录 `make menuconfig` 后拷回来）再推送，或直接手动触发一次构建。

## 软件源

| feed | 来源与分支 | 说明 |
|---|---|---|
| `packages` | `immortalwrt/packages` `openwrt-24.10` | 与源码分支严格对应 |
| `luci` | `immortalwrt/luci` `openwrt-24.10` | 同上，版本形如 `26.246.…` |
| `routing` / `telephony` | `openwrt/routing`、`openwrt/telephony` `openwrt-24.10` | 同上 |
| `golang`（替换） | `sbwml/packages_lang_golang` `24.x` | 当前没有 go 包要用，仅作备用 |
| `easytier` | `EasyTier/luci-app-easytier` `main` | **只挂源、不启用**，不参与编译（见下） |

两点原则：

- **不要跨分支**。immortalwrt 已经有 `openwrt-25.12` 和 `master`，但 luci/packages 与 24.10 的内核、ucode、js 接口不匹配，混用会直接编译失败。要换新分支就得连源码一起换。
- **同名包只能有一个**。将来想用第三方 feed 覆盖某个包时，先 `rm -rf package/feeds/packages/<pkg>` 再 `./scripts/feeds install -f -p <新feed> <pkg>` —— `feeds install -a` 会跳过同名包（先装的赢），不显式指定是不会生效的。

`diy-part1.sh` 末尾还留了 helloworld / mosdns(v5) / lucky / openlist2 四条注释，需要时取消注释即可。

除了 feed 层面，`diy-part2.sh` 还会**就地给 `zerotier` 升版**：`1.14.1` → `1.16.2`。immortalwrt 和 openwrt 官方的 `openwrt-24.10` 分支都还停在 1.14.1，只有 25.12 / master 跟到了 1.16.2；两边配方只差版本号、hash、许可证字段和 `ZT_NONFREE` 开关，所以直接改 Makefile 更省事。

### EasyTier（挂了源，但没启用）

EasyTier 是去中心化的组网方案，和 ZeroTier 定位相近，但走 P2P 打洞、可以走公网中继，跨运营商不容易被限速。feed 已经加进 `diy-part1.sh`（`EasyTier/luci-app-easytier`，main），**但 `.config` 里没有启用，所以目前的固件里不会有它，也不占用编译时间**。

以后想用的时候，在 `.config` 里加两行：

```
CONFIG_PACKAGE_luci-app-easytier=y   # LuCI 界面，依赖 kmod-tun + luci-compat（两个都已经在配置里）
CONFIG_PACKAGE_easytier=y            # 核心二进制，v2.7.0
```

两个好处：它**不需要 Rust 工具链**（`Build/Prepare` 直接下上游预编译的 `easytier-linux-aarch64-v*.zip`，`Build/Compile` 是空的），aarch64 在支持列表里；所以真开了也只是多几 MB 加几十秒下载，不像 xray 那样要现编。另外 `luci-app-easytier` 本身不依赖 `easytier` 核心包，它支持运行时在线下载二进制，只想先看界面也可以只开界面那一个。

## 启用的软件包

`.config` 经 `make defconfig` 展开后有 **435 个 `=y`**：其中 158 个内核模块、10 个 LuCI 应用、11 个中文语言包。上一次构建（2026.10.07）实际装进固件的是 397 个包。

### LuCI 应用

| 应用 | 作用 |
|---|---|
| `luci-app-mtwifi-cfg` | MT7981 闭源 WiFi 配置（信道 / 功率 / 漫游） |
| `luci-app-turboacc-mtk` | 硬件 + 软件 NAT 加速，带 BBR |
| `luci-app-eqos-mtk` | 按 IP / MAC 限速 |
| `luci-app-wrtbwmon` | 每设备流量统计 |
| `luci-app-zerotier` | ZeroTier 组网 |
| `luci-app-wol` | 网络唤醒（配 `etherwake`） |
| `luci-app-ttyd` | 网页终端 |
| `luci-app-ramfree` | 一键释放内存 |
| `luci-app-package-manager` | 图形化软件包管理 |
| `luci-app-firewall` | 防火墙 |

### 界面与语言

- `luci-base`、`luci-mod-admin-full`、`luci-mod-network`、`luci-mod-status`、`luci-mod-system`、`luci-light`
- `luci-compat` + `luci-lua-runtime`（老式 Lua 插件需要；`luci-app-easytier` 也是走这层）
- 主题只有 `luci-theme-bootstrap`
- 中文：`luci-i18n-{base,firewall,mtwifi-cfg,turboacc-mtk,eqos-mtk,wrtbwmon,zerotier,wol,ttyd,ramfree,package-manager}-zh-cn`
- `default-settings` + `default-settings-chn`（默认中文界面、中国时区）

### 网络底座

`dnsmasq-full`（DHCP/DNS，带 dnssec / ipset / nftset）、`odhcpd-ipv6only`、`firewall4` + `nftables-json`、`dropbear` + `openssh-sftp-server`、`uhttpd`、`ppp` + `ppp-mod-pppoe`、`wpad-openssl`、`iw` / `iwinfo` / `wireless-tools` / `wireless-regdb`、`ethtool`、`ip-tiny`、`iptables-nft` + 一批 `iptables-mod-*`、`ipset`、`tc-tiny`、`tcpdump`、`uboot-envtools`

### 存储 / USB

`block-mount` + `automount` + `blockd`、`e2fsprogs`、`fdisk`、`ntfs3-mount`、`usbutils` / `usbids`
内核侧：`kmod-fs-btrfs` / `ext4` / `exfat` / `ntfs3` / `vfat`、`kmod-usb-storage` / `-extras` / `-uas`、`kmod-usb-xhci-mtk` / `ehci` / `usb3`

### 内核模块里比较关键的

`kmod-tun`（ZeroTier / EasyTier 都要）、`kmod-wireguard`、`kmod-tcp-bbr`、`kmod-ipt-offload`、`kmod-nft-offload`、`kmod-ipt-fullconenat`、`kmod-ipt-ipset`、`kmod-ipt-tproxy` / `kmod-nft-tproxy`、`kmod-zram`、`kmod-bonding`、`kmod-macvlan` / `kmod-veth`

### 其它

`zram-swap`、`htop`、`nano`、`openssl-util`、`ca-bundle`、MTK 私有工具（`mtwifi-cfg`、`mtkhqos_util`、`switch`、`mii_mgr`、`mtk-smp`、`regs`、`autocore-arm`）

### 两个小注

- `.config` 里那 3 条 `luci-app-passwall_INCLUDE_*` 是孤儿选项（主包从不启用），等效于不存在。
- `knot-resolver_dnstap` 是被 `dnsmasq-full` 的依赖链带进来的，不是主动选的。

## 自动化

| 工作流 | 说明 |
|---|---|
| `Build OpenWrt` | 手动 `Run workflow` 构建，也可以用 `repository_dispatch` 触发。产物自动发布到 Release，tag 形如 `2026.11.22-1425-immortalwrt24.10-6.6-nx30pro` |
| `Update Checker` | 每天 02:00（北京时间）检查上游分支 HEAD，有更新就触发一次构建 |

需要配置的 Secret：

- `ACTIONS_TRIGGER_PAT`：Classic PAT，需 `repo` 权限，用于 `repository_dispatch`（`GITHUB_TOKEN` 触发不了其他工作流）
- `TELEGRAM_BOT_TOKEN` / `TELEGRAM_CHAT_ID`：可选，只在用 `ssh: true` 调试时用于取 tmate 连接信息

> ⚠️ 本仓库是 fork，GitHub 默认禁用 fork 的定时工作流（`disabled_fork`）。第一次使用请到 Actions 页面点一次 **Enable workflow**，否则 `Update Checker` 不会自动跑。

## 目录结构

```
.config                              # 固件配置（menuconfig 输出）
diy-part1.sh                         # feeds update 之前的自定义（加第三方 feed 等）
diy-part2.sh                         # feeds 安装之后的源码替换（golang 语言包等）
files/etc/uci-defaults/99-custom     # 预置配置模板（默认全注释，启用需加可执行权限）
.github/workflows/build-openwrt.yml  # 构建流程
.github/workflows/update-checker.yml # 上游更新检查
```

想预置 WiFi 名称密码、改 LAN IP、关 IPv6，直接在 `files/etc/uci-defaults/99-custom` 里取消注释对应片段，随固件编译进去，不用刷完再点。

## 已知情况

- `.config` 里的 `CONFIG_TARGET_ROOTFS_PARTSIZE=160` 是从父仓库（RAX3000M）带过来的遗留值，对 64 MB UBI 的 NX30 Pro 没有实际作用，未改动以免影响现有的可编译状态。
- Release 里只保留固件和 `sha256sums`；`packages/`、`*.manifest`、`*.buildinfo` 在打包前已删除。
- 编译日志只在失败时上传（artifact 名 `build-log_*`，保留 7 天），构建成功不保留。
- 没有启用 PassWall / xray / sing-box：这台 256MB 内存 + MT7981 扛不住，属于主动放弃而不是漏配。
- `.config` 里那几条 `CONFIG_PACKAGE_luci-app-passwall_INCLUDE_*` 是孤儿选项（主包不启用），留着无害，也可以顺手删掉。

## 致谢

模板来自 [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)，源码来自 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6) 与 [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)。

## License

[MIT](LICENSE)
