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

# 其它可选的第三方源（需要时取消注释；注意不要与默认 feed 里的包重名）
# echo 'src-git helloworld https://github.com/fw876/helloworld.git;master' >> feeds.conf.default
# echo 'src-git mosdns https://github.com/sbwml/luci-app-mosdns.git;v5' >> feeds.conf.default
# echo 'src-git lucky https://github.com/gdy666/luci-app-lucky.git;main' >> feeds.conf.default
# echo 'src-git openlist2 https://github.com/sbwml/luci-app-openlist2.git;main' >> feeds.conf.default
