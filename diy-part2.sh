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

# 修改IP(C类地址)和主机名
sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/255.255.255.0/255.255.0.0/g' package/base-files/files/bin/config_generate
sed -i 's/OpenWrt/ZJS/g' package/base-files/files/bin/config_generate

# change the login password
sed -i '/root::0:0:99999:7:::/s/^/#/' package/lean/default-settings/files/zzz-default-settings
sed -i '/root:::0:99999:7:::/s/^/#/' package/lean/default-settings/files/zzz-default-settings
sed -i 's/root:::0:99999:7:::/root:$1$iZM.01X5$xfeRwcqbhN\/60\/2SUPwDc\/:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# Import external feeds - JerryKuKu Argon
sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-argon-mod/root/etc/uci-defaults/90_luci-theme-argon
sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-netgear/root/etc/uci-defaults/30_luci-theme-netgear
sed -i 's/Bootstrap/Design/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci/Makefile

# ttyd更改ip后不能访问
sed -i '/${interface:+-i $interface}/s/^/#/' feeds/packages/utils/ttyd/files/ttyd.init
sed '/@lan/d' feeds/packages/utils/ttyd/files/ttyd.config

# 修正wifi不能启动问题
sed -i '/uci commit fstab/a\\nlanCheck=`uci get network.lan.ifname`\nuci set network.lan.ifname="$lanCheck rai0 ra0"\nuci commit network' package/lean/default-settings/files/zzz-default-settings

# 添加msd_lite
rm -rf feeds/packages/net/msd_lite
git clone https://github.com/ximiTech/msd_lite.git feeds/packages/net/msd_lite
git clone https://github.com/ximiTech/luci-app-msd_lite.git package/lean/luci-app-msd_lite
sed -i 's/${vendorid:+-V "$vendorid"}/${vendorid:+-V "" "-x 0x3c:$vendorid"}/g' package/network/config/netifd/files/lib/netifd/proto/dhcp.sh

# 添加openclash
mkdir package/openclash
cd package/openclash
git init
git remote add origin https://github.com/vernesong/OpenClash.git
git config core.sparsecheckout true
echo "luci-app-openclash" >> .git/info/sparse-checkout
git pull --depth 1 origin master
git branch --set-upstream-to=origin/master master
mv luci-app-openclash ../
cd ../../
rm -rf package/openclash
