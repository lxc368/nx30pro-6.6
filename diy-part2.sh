#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

set -e

# 注：libfuse-dev 等编译依赖已统一移到 workflow 的 DEPS 里安装（apt 需要 -y，
# 放在这里非交互环境下会卡住），此脚本只做源码层面的替换。

# ---------------------------------------------------------------------------
# 1) golang 语言包
#    xray-core 26.11.9 的 go.mod 要求 go1.27，sing-box 1.14.4 要求 go1.25.5，
#    源码树自带 / 原先用的 24.x 都编不过，改用 sbwml 的 27.x
# ---------------------------------------------------------------------------
rm -rf feeds/packages/lang/golang
git clone --depth 1 https://github.com/sbwml/packages_lang_golang -b 27.x feeds/packages/lang/golang

# ---------------------------------------------------------------------------
# 2) 用 passwall 上游的最新版覆盖 immortalwrt 里的旧快照
#    （旧版 luci-app-passwall 25.12.16 / xray-core 25.2.21）
#    feeds install -a 已经把旧版链进 package/feeds/，这里先撤掉再强制装新版
# ---------------------------------------------------------------------------
rm -rf package/feeds/luci/luci-app-passwall
./scripts/feeds install -f -p passwall_luci luci-app-passwall

# 代理核心包：与 immortalwrt/packages 重名的那些，统一换成上游版本
# （smartdns 故意不覆盖，它和 luci-app-smartdns 版本绑定，保持 immortalwrt 的）
CORE_PKGS="xray-core sing-box shadowsocks-rust hysteria naiveproxy shadow-tls \
v2ray-geodata geoview chinadns-ng dns2socks microsocks tcping v2ray-plugin \
xray-plugin simple-obfs"

for p in $CORE_PKGS; do
	rm -rf "package/feeds/packages/$p"
done
./scripts/feeds install -f -p passwall_packages $CORE_PKGS

# ---------------------------------------------------------------------------
# 3) 打开 PassWall 主开关
#    .config 里只留了 luci-app-passwall_INCLUDE_* 这些子选项，主包从来没启用，
#    所以之前发布的固件里其实没有 PassWall。这里补上（make defconfig 会补齐依赖）
# ---------------------------------------------------------------------------
grep -q '^CONFIG_PACKAGE_luci-app-passwall=y' .config || \
	echo 'CONFIG_PACKAGE_luci-app-passwall=y' >> .config
