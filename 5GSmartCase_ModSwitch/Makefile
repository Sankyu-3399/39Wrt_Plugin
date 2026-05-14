include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-5gsmartcase-modswitch
PKG_VERSION:=1.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Sankyu
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-5gsmartcase-modswitch
  SECTION:=luci
  CATEGORY:=39Wrt_Plugin
  TITLE:=LuCI support for 5G Smart Case USB mode switch
  DEPENDS:=+adb +luci +luci-base +luci-compat
  PKGARCH:=all
endef

define Package/luci-app-5gsmartcase-modswitch/description
  Switch 5G smart case permanent USB network mode over the only connected ADB device.
endef

define Build/Compile
endef

define Package/luci-app-5gsmartcase-modswitch/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/smartcase_modswitch.lua $(1)/usr/lib/lua/luci/controller/smartcase_modswitch.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/smartcase_modswitch
	$(INSTALL_DATA) ./luasrc/view/smartcase_modswitch/index.htm $(1)/usr/lib/lua/luci/view/smartcase_modswitch/index.htm
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/smartcase_modswitch.po $(1)/usr/lib/lua/luci/i18n/smartcase_modswitch.zh-cn.lmo
	po2lmo ./po/zh_Hans/smartcase_modswitch.po $(1)/usr/lib/lua/luci/i18n/smartcase_modswitch.zh_Hans.lmo
endef

$(eval $(call BuildPackage,luci-app-5gsmartcase-modswitch))
