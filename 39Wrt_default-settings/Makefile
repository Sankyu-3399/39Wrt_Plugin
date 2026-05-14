include $(TOPDIR)/rules.mk

PKG_NAME:=39Wrt_default-settings
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Sankyu
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/39Wrt_default-settings
  SECTION:=sankyu
  CATEGORY:=39Wrt_Plugin
  TITLE:=39Wrt default settings
  DEPENDS:=+miniupnpd +ttyd +luci-base +luci-mod-status +luci-mod-network
  PKGARCH:=all
endef

define Package/39Wrt_default-settings/description
  Apply 39Wrt defaults for DHCP, IPv6 RA/DHCPv6, UPnP, ttyd login command,
  and LuCI menu visibility.
endef

define Build/Compile
endef

define Package/39Wrt_default-settings/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-39wrt-default-settings $(1)/etc/uci-defaults/99-39wrt-default-settings
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./files/usr/share/luci/menu.d/zz-39wrt-default-settings.json $(1)/usr/share/luci/menu.d/zz-39wrt-default-settings.json
	$(INSTALL_DIR) $(1)/usr/share/39wrt-default-settings
	$(INSTALL_DATA) ./files/usr/share/39wrt-default-settings/status-index-bandwidth.patch.sed $(1)/usr/share/39wrt-default-settings/status-index-bandwidth.patch.sed
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/status/include
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/status/include/31_bandwidth.js $(1)/www/luci-static/resources/view/status/include/31_bandwidth.js
endef

$(eval $(call BuildPackage,39Wrt_default-settings))
