include $(TOPDIR)/rules.mk

PKG_NAME:=JDCloud_AX1800Pro_CPE
PKG_VERSION:=1.0
PKG_RELEASE:=2
PKG_MAINTAINER:=Sankyu
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/JDCloud_AX1800Pro_CPE
  SECTION:=sankyu
  CATEGORY:=39Wrt_Plugin
  TITLE:=JDCloud AX1800 Pro CPE network layout
  DEPENDS:=@TARGET_ipq60xx +odhcp6c +odhcpd-ipv6only
  PKGARCH:=all
endef

define Package/JDCloud_AX1800Pro_CPE/description
  Configure jdcloud,ax1800-pro as CPE layout: eth0 eth1 eth2 eth3 for LAN,
  usb0 for WAN, and IPv6 relay for LAN clients.
endef

define Build/Compile
endef

define Package/JDCloud_AX1800Pro_CPE/install
	$(INSTALL_DIR) $(1)/etc/board.d
	$(INSTALL_BIN) ./files/etc/board.d/99_jdcloud_ax1800pro_cpe $(1)/etc/board.d/99_jdcloud_ax1800pro_cpe
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-jdcloud-ax1800pro-cpe-network $(1)/etc/uci-defaults/99-jdcloud-ax1800pro-cpe-network
endef

$(eval $(call BuildPackage,JDCloud_AX1800Pro_CPE))
