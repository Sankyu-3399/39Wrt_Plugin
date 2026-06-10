include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

PKG_NAME:=luci-mod-39wrt-luci-custom
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

define Package/luci-mod-39wrt-luci-custom
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=39Wrt LuCI overview links and firmware cloud tab
  DEPENDS:=+luci-base +luci-mod-status +luci-mod-system
  PKGARCH:=all
  MAINTAINER:=sankyu
endef

define Package/luci-mod-39wrt-luci-custom/description
Customizes the LuCI status overview firmware version row and adds a firmware cloud tab to the backup/flash page.
endef

define Build/Compile
	:
endef

define Package/luci-mod-39wrt-luci-custom/install
	$(INSTALL_DIR) $(1)/usr/share/39wrt-luci-custom/status
	$(INSTALL_DIR) $(1)/usr/share/39wrt-luci-custom/system
	$(INSTALL_DIR) $(1)/usr/libexec/39wrt-luci-custom
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/usr/share/39wrt-luci-custom/status/10_system.js $(1)/usr/share/39wrt-luci-custom/status/10_system.js
	$(INSTALL_DATA) ./files/usr/share/39wrt-luci-custom/system/flash.js $(1)/usr/share/39wrt-luci-custom/system/flash.js
	$(INSTALL_BIN) ./files/usr/libexec/39wrt-luci-custom/apply $(1)/usr/libexec/39wrt-luci-custom/apply
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-39wrt-luci-custom $(1)/etc/uci-defaults/99-39wrt-luci-custom
endef

define Package/luci-mod-39wrt-luci-custom/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
/usr/libexec/39wrt-luci-custom/apply apply || exit 1
exit 0
endef

define Package/luci-mod-39wrt-luci-custom/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
[ -x /usr/libexec/39wrt-luci-custom/apply ] && /usr/libexec/39wrt-luci-custom/apply restore
exit 0
endef

$(eval $(call BuildPackage,luci-mod-39wrt-luci-custom))
