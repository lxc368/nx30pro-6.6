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

## 致谢

模板来自 [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)，源码来自 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6) 与 [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)。

## License

[MIT](LICENSE)
