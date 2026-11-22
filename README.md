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

PassWall、ZeroTier、TurboACC（`turboacc-mtk`）、EQOS（`eqos-mtk`）、WOL、wrtbwmon、ramfree、ttyd、`mtwifi-cfg`、`package-manager`，主题为 Bootstrap。

需要增删软件包：改 `.config`（在源码目录 `make menuconfig` 后拷回来）再推送，或直接手动触发一次构建。

> PassWall 的主开关 `CONFIG_PACKAGE_luci-app-passwall` 之前从未在 `.config` 里启用（只配了 `INCLUDE_*` 子选项），所以 2026.10 及更早的固件里**没有** PassWall；现在由 `diy-part2.sh` 补上。

## 软件源

| feed | 来源与分支 | 说明 |
|---|---|---|
| `packages` | `immortalwrt/packages` `openwrt-24.10` | 与源码分支严格对应 |
| `luci` | `immortalwrt/luci` `openwrt-24.10` | 同上，版本形如 `26.246.…` |
| `routing` / `telephony` | `openwrt/routing`、`openwrt/telephony` `openwrt-24.10` | 同上 |
| `passwall_luci` | `Openwrt-Passwall/openwrt-passwall` `main` | 覆盖 immortalwrt 的 25.12.16 快照 |
| `passwall_packages` | `Openwrt-Passwall/openwrt-passwall-packages` `main` | xray-core / sing-box 等核心，取最新 |
| `golang`（替换） | `sbwml/packages_lang_golang` `27.x` | xray-core 26.11 要求 go1.27 |

两点原则：

- **不要跨分支**。immortalwrt 已经有 `openwrt-25.12` 和 `master`，但 luci/packages 与 24.10 的内核、ucode、js 接口不匹配，混用会直接编译失败。要换新分支就得连源码一起换。
- **同名包只能有一个**。第三方 feed 里与默认 feed 重名的包，`feeds install -a` 会同时链进来，所以 `diy-part2.sh` 里显式删掉旧链接再 `feeds install -f -p <feed> <pkg>` 强制用新版。

`diy-part1.sh` 末尾还留了 helloworld / mosdns(v5) / lucky / openlist2 四条注释，需要时取消注释即可。

除了 feed 层面，`diy-part2.sh` 还会**就地给 `zerotier` 升版**：`1.14.1` → `1.16.2`。immortalwrt 和 openwrt 官方的 `openwrt-24.10` 分支都还停在 1.14.1，只有 25.12 / master 跟到了 1.16.2；两边配方只差版本号、hash、许可证字段和 `ZT_NONFREE` 开关，所以直接改 Makefile 更省事。

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
- 加入 PassWall 后 rootfs 会从约 15 MB 涨到 25–35 MB（xray + sing-box + shadowsocks-rust 都不小），UBI 分区 64 MB 仍然够用；如果不需要 sing-box，把 `.config` 里的 `CONFIG_PACKAGE_luci-app-passwall_INCLUDE_SingBox` 关掉能省最多。
- `xray-core` / `sing-box` 由 go1.27 交叉编译，单是这两个包会多花 20–40 分钟。

## 致谢

模板来自 [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)，源码来自 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6) 与 [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)。

## License

[MIT](LICENSE)
