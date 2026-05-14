# 39Wrt_Plugin

39Wrt 的 OpenWrt 插件包目录，插件统一显示在 `make menuconfig` 的 `39Wrt_Plugin` 分类下。

## 插件列表

### 1. JDCloud_AX1800Pro_CPE

- 入口：`make menuconfig -> 39Wrt_Plugin -> JDCloud_AX1800Pro_CPE`
- LuCI 页面：无
- 作用：仅针对 `jdcloud,ax1800-pro` 生效，用于配置京东云 AX1800 Pro 的 CPE 网络布局。
- LAN：`eth0 eth1 eth2 eth3`
- WAN/WAN6：`usb0`
- IPv6：使用 `relay` 模式，适合把上游 IPv6 透传给 LAN 侧客户端。

### 2. luci-app-5gsmartcase-modswitch

- 入口：`make menuconfig -> 39Wrt_Plugin -> luci-app-5gsmartcase-modswitch`
- LuCI 入口：`网络 -> 5G智慧壳网络模式切换`
- 作用：通过唯一连接的 ADB 设备，把 5G 智慧壳的 USB 网络模式永久切换为：
  - `CDC-NCM`
  - `CDC-ECM`
  - `RNDIS`
- 切换后会写入智慧壳内部配置，并重启智慧壳让配置生效。

### 3. 39Wrt_default-settings

- 入口：`make menuconfig -> 39Wrt_Plugin -> 39Wrt_default-settings`
- LuCI 页面：无独立页面
- 作用：提供 39Wrt 默认配置：
  - UPnP 默认开启
  - DHCP 起始地址：`10`
  - DHCP 客户数：`200`
  - dnsmasq 顺序分配 IP 默认开启
  - ttyd 默认命令改为：`/bin/login -f root`
  - 隐藏部分 LuCI 菜单：
    - `状态 -> 路由`
    - `状态 -> 防火墙`
    - `状态 -> 信道分析`
    - `网络 -> 网络诊断`
  - 将 `状态 -> 实时信息 -> 带宽` 图表移动到 `状态 -> 概览` 中显示
- 特别说明：如果同时选择 `JDCloud_AX1800Pro_CPE`，本插件不会参与 IPv6 相关设置，IPv6 最终由 `JDCloud_AX1800Pro_CPE` 接管。

## 使用方式

把本目录放入 OpenWrt 源码树的插件目录，例如：

```text
package/39Wrt_Plugin/
```

然后执行：

```sh
make menuconfig
```

进入：

```text
39Wrt_Plugin
```

选择需要的插件后正常编译固件即可。
