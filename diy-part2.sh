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
#    当前 .config 里没有依赖 golang 的包（xray/sing-box 等代理核心不装），这一步
#    不会被触发编译，保留只是为了以后加插件时不去抓源码树里那份过老的 go。
# ---------------------------------------------------------------------------
rm -rf feeds/packages/lang/golang
git clone --depth 1 https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# ---------------------------------------------------------------------------
# 2) ZeroTier：immortalwrt/packages 的 24.10 分支停在 1.14.1（2024 年的版本），
#    25.12 / master 分支早就是 1.16.2 了。两边的配方只差版本号、hash、
#    许可证字段和一个 1.16 新增的 ZT_NONFREE 开关，patches/ 完全相同
#    （已实测 6 个 patch 全部能干净应用到 1.16.2 源码），所以就地改而不是换 feed。
# ---------------------------------------------------------------------------
ZT_MK=feeds/packages/net/zerotier/Makefile
if grep -q '^PKG_VERSION:=1\.14\.1$' "$ZT_MK"; then
	sed -i \
		-e 's/^PKG_VERSION:=.*/PKG_VERSION:=1.16.2/' \
		-e 's/^PKG_RELEASE:=.*/PKG_RELEASE:=1/' \
		-e 's/^PKG_HASH:=.*/PKG_HASH:=2c607f573c6e38815433af289d364a689a203b18b51125f06c4472014d0657f0/' \
		-e 's/^PKG_LICENSE:=.*/PKG_LICENSE:=MPL-2.0/' \
		"$ZT_MK"
	# 1.16 的 make-linux.mk 默认 ZT_NONFREE=1（会打开非自由的控制面组件），
	# master 分支的配方显式关掉它，这里保持一致
	grep -q 'ZT_NONFREE' "$ZT_MK" || echo 'MAKE_FLAGS += ZT_NONFREE=0' >> "$ZT_MK"
else
	echo "WARNING: $ZT_MK 不是 1.14.1（feed 可能已经更新），跳过 zerotier 版本升级"
fi
