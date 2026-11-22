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

# 增补 feed：PassWall 上游
# immortalwrt 自带的 luci-app-passwall 是 25.12.16 的快照，核心包更旧
# （xray-core 停在 2025-03 的 25.2.21），这里用上游 main 覆盖，见 diy-part2.sh
echo 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' >> feeds.conf.default
echo 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' >> feeds.conf.default

# 其它可选的第三方源（需要时取消注释；注意不要与上面的包重名）
# echo 'src-git helloworld https://github.com/fw876/helloworld.git;master' >> feeds.conf.default
# echo 'src-git mosdns https://github.com/sbwml/luci-app-mosdns.git;v5' >> feeds.conf.default
# echo 'src-git lucky https://github.com/gdy666/luci-app-lucky.git;main' >> feeds.conf.default
# echo 'src-git openlist2 https://github.com/sbwml/luci-app-openlist2.git;main' >> feeds.conf.default
