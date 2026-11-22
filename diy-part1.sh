#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# 默认 feed（源码树的 feeds.conf.default）已经和 24.10 分支对齐，不要改成 master 或 25.12：
# 跨分支的 luci/packages 与内核、ucode、js 接口不匹配，会直接编译失败。

# 注：PassWall（xray-core / sing-box）已经评估过并放弃 —— 这台的 256MB 内存 + MT7981
# 跑不动，加了也是摆设，所以这里不挂 passwall feed。

# 增补 feed：EasyTier（去中心化组网，类 ZeroTier 但走 P2P 打洞，跨运营商不容易被限速）
# 注意：这里只挂源、不在 .config 里启用，所以不会进固件、也不参与编译。
# 以后想用再打开 CONFIG_PACKAGE_luci-app-easytier=y（界面，依赖 kmod-tun/luci-compat，都已具备）
# 和 CONFIG_PACKAGE_easytier=y（核心，2.7.0）。
# 它不做 Rust 编译：Build/Prepare 直接拉上游预编译的 aarch64 包，开启后只多几 MB。
echo 'src-git easytier https://github.com/EasyTier/luci-app-easytier.git;main' >> feeds.conf.default

# 其它可选的第三方源（需要时取消注释；注意不要与默认 feed 里的包重名）
# echo 'src-git helloworld https://github.com/fw876/helloworld.git;master' >> feeds.conf.default
# echo 'src-git mosdns https://github.com/sbwml/luci-app-mosdns.git;v5' >> feeds.conf.default
# echo 'src-git lucky https://github.com/gdy666/luci-app-lucky.git;main' >> feeds.conf.default
# echo 'src-git openlist2 https://github.com/sbwml/luci-app-openlist2.git;main' >> feeds.conf.default
