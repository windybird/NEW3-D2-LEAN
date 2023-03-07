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

# 1. Modify default IP
sed -i 's/192.168.1.1/10.10.10.13/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.$((addr_offset++)).1/10.10.$((addr_offset++)).13/g' package/base-files/files/bin/config_generate

# 2. change the login password
sed -i '/root::0:0:99999:7:::/s/^/#/' package/lean/default-settings/files/zzz-default-settings
sed -i '/root:::0:99999:7:::/s/^/#/' package/lean/default-settings/files/zzz-default-settings
sed -i 's/root:::0:99999:7:::/root:$1$iZM.01X5$xfeRwcqbhN\/60\/2SUPwDc\/:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# 3. Import external feeds - JerryKuKu Argon
rm -rf feeds/luci/themes/luci-theme-bootstrap-mod
rm -rf feeds/luci/themes/luci-theme-material
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon-mod
rm -rf feeds/luci/themes/luci-theme-netgear
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon

# 4. add luci-app-vssr
git clone https://github.com/jerrykuku/lua-maxminddb.git  package/lean/lua-maxminddb
git clone https://github.com/jerrykuku/luci-app-vssr.git  package/lean/luci-app-vssr

# 5. defaut themes
sed -i 's/Bootstrap/Argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 6. add luci-app-oaf
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# 7. ttyd更改ip后不能访问
sed -i '/exit 0/i sed -i '"'"'/${interface:+-i $interface}/s/^/#/'"'"' /etc/init.d/ttyd' package/lean/default-settings/files/zzz-default-settings

# 8. 修正wifi不能启动问题
sed -i '/uci commit fstab/a\\nlanCheck=`uci get network.lan.ifname`\nuci set network.lan.ifname="$lanCheck rai0 ra0"\nuci commit network' package/lean/default-settings/files/zzz-default-settings

# 9. frp
sed -i '/PKG_BUILD_DEPENDS:=golang/host upx\/host/PKG_BUILD_DEPENDS:=golang/host' feeds/packages/net/frp/Makefile
sed -i '/$(STAGING_DIR_HOST)\/bin\/upx --lzma --best $$(1)\/usr\/bin\/$(1) || true/s/^/#/' feeds/packages/net/frp/Makefile
