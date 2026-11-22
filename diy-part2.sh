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

# 替换 golang 语言包：feeds/packages/lang/golang 版本偏旧，部分插件需要 go1.24
rm -rf feeds/packages/lang/golang
git clone --depth 1 https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang
