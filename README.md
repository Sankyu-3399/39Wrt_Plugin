# 39Wrt_Plugin

39Wrt 的 OpenWrt / QSDK 插件集合仓库。

本仓库用于统一维护 39Wrt 相关默认配置、设备专用配置、LuCI 插件、主题修改版以及 5G / CPE 相关扩展。插件统一归类到 `make menuconfig` 的 `39Wrt_Plugin` 分类下，方便在不同 OpenWrt / QSDK 源码树中复用。

## 仓库内容

```text
39Wrt_Plugin
├── 39Wrt_default-settings
├── 5GSmartCase_ModSwitch
├── JDCloud_AX1800Pro_CPE
├── luci-app-adguardhome
├── luci-theme-aurora_mod
└── README.md
```

> 实际目录以当前分支内容为准。不同阶段可能只启用其中一部分插件。

## 使用方式

将本仓库放入 OpenWrt 源码树的 package 目录，例如：

```sh
cd ~/OpenWrt/package
git clone https://github.com/Sankyu-3399/39Wrt_Plugin.git
```

然后回到源码根目录：

```sh
cd ~/OpenWrt
make menuconfig
```

进入：

```text
39Wrt_Plugin
```

选择需要的插件后正常编译固件。

如果 menuconfig 中没有显示插件，可以执行：

```sh
make defconfig
make menuconfig
```

## 插件列表

### 1. 39Wrt_default-settings

39Wrt 默认系统配置包。

菜单位置：

```text
make menuconfig -> 39Wrt_Plugin -> 39Wrt_default-settings
```

LuCI 页面：

```text
无独立 LuCI 页面
```

主要作用：

- 设置 39Wrt 默认系统参数
- 调整 DHCP 默认地址池
- 默认关闭 LAN DHCPv6
- 默认启用 UPnP
- 默认启用 dnsmasq 顺序分配 IP
- 设置 ttyd 默认 root 自动登录
- 修补 LuCI 状态页，将实时带宽卡片显示到状态概览
- 清理 LuCI 首页索引缓存

默认配置项：

```sh
uci set dhcp.lan.start='10'
uci set dhcp.lan.limit='200'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.@dnsmasq[0].sequential_ip='1'
uci set upnpd.config.enabled='1'
uci set ttyd.@ttyd[0].command='/bin/login -f root'
```

默认行为说明：

- DHCP 地址池从 `10` 开始
- DHCP 客户端数量为 `200`
- LAN 侧 DHCPv6 默认禁用
- dnsmasq 默认按顺序分配 IP
- miniupnpd 默认启用
- ttyd 默认使用 root 自动登录
- LuCI 状态页会额外显示实时带宽卡片

特殊逻辑：

如果同时选择 `JDCloud_AX1800Pro_CPE`，`39Wrt_default-settings` 会检测到 JDCloud CPE 配置包，并为其保留 IPv6 relay 相关设置。

注意：

`/etc/uci-defaults/` 中的脚本只会在首次启动或恢复出厂后执行。已经启动过的设备不会重复执行 defaults 脚本，除非手动运行或清空 overlay。

---

### 2. JDCloud_AX1800Pro_CPE

京东云 AX1800 Pro CPE 网络布局配置包。

菜单位置：

```text
make menuconfig -> 39Wrt_Plugin -> JDCloud_AX1800Pro_CPE
```

LuCI 页面：

```text
无独立 LuCI 页面
```

适用设备：

```text
jdcloud,ax1800-pro
```

主要作用：

为京东云 AX1800 Pro 配置 CPE 场景下的网络布局。

网络布局：

```text
LAN  : eth0 eth1 eth2 eth3
WAN  : usb0
WAN6 : usb0
```

IPv4 行为：

```text
WAN 使用 DHCP IPv4
```

IPv6 行为：

```text
WAN6 使用 DHCPv6
LAN 使用 IPv6 relay
```

典型拓扑：

```text
5G Modem / 上级路由
        |
      usb0
        |
JDCloud AX1800 Pro
        |
      LAN 客户端
```

适用 IPv6 场景：

```text
上级设备只提供单 /64 IPv6
无 Prefix Delegation
JDCloud AX1800 Pro 不重新分配 IPv6 前缀
LAN 客户端通过 relay 获取上级 IPv6
```

典型配置逻辑：

```sh
set network.wan.device='usb0'
set network.wan.proto='dhcp'

set network.wan6.device='usb0'
set network.wan6.proto='dhcpv6'
set network.wan6.reqaddress='try'
set network.wan6.reqprefix='no'

set dhcp.lan.ra='relay'
set dhcp.lan.dhcpv6='relay'
set dhcp.lan.ndp='relay'
```

注意：

该插件只对 `board_name` 为 `jdcloud,ax1800-pro` 的设备生效。其他设备选择该插件不会应用网络布局。

---

### 3. 5GSmartCase_ModSwitch

5G 智慧壳 USB 网络模式切换插件。

菜单位置：

```text
make menuconfig -> 39Wrt_Plugin -> 5GSmartCase_ModSwitch
```

LuCI 页面：

```text
网络 -> 5G Smart Case Network Mode Switch
```

主要作用：

通过 ADB 操作 5G 智慧壳，读取和切换其 USB 网络模式。

支持模式：

```text
1 = CDC-NCM
2 = CDC-ECM
3 = RNDIS
```

主要功能：

- ADB 在线检测
- 自动读取当前 USB 网络模式
- 永久切换 USB 网络模式
- 切换后重启智慧壳使配置生效
- ADB Shell 面板
- ADB 未连接时自动隐藏 Shell 面板
- 响应式卡片布局
- 适配桌面端、窄屏、移动端窗口比例

当前模式读取逻辑：

```sh
adb shell cat /mnt/data/mode.cfg
```

切换逻辑：

```sh
adb shell 'echo <mode> > /mnt/data/mode.cfg'
```

ADB Shell：

当检测到 ADB 设备已连接时，LuCI 页面会显示 ADB Shell 卡片，可直接执行 ADB Shell 命令。

ADB 离线时：

- 页面显示 ADB 未连接
- Shell 卡片自动隐藏
- 不允许执行 Shell 命令

注意：

该插件依赖系统中存在可用的 `adb` 命令。请确保固件已包含 ADB 工具。

安全提醒：

ADB Shell 可以执行设备端命令，建议仅在可信内网环境中使用，不要将 LuCI 管理页面暴露到公网。

---

### 4. luci-app-adguardhome

AdGuard Home LuCI 管理插件。

来源：

```text
https://github.com/rufengsuixing/luci-app-adguardhome
```

菜单位置：

```text
make menuconfig -> 39Wrt_Plugin -> luci-app-adguardhome
```

LuCI 页面：

```text
服务 -> AdGuard Home
```

主要功能：

- AdGuard Home 管理
- Core 下载
- Core 更新
- 运行状态检测
- 日志查看
- 手动配置
- 模板配置
- 重载配置

下载链接相关文件：

```text
root/usr/share/AdGuardHome/links.txt
root/usr/share/AdGuardHome/update_core.sh
```

默认配置模板：

```text
root/usr/share/AdGuardHome/AdGuardHome_template.yaml
```

说明：

本仓库中的版本主要用于集成到 `39Wrt_Plugin` 分类，方便在 39Wrt 固件中统一选择和维护。

---

### 5. luci-theme-aurora_mod

Aurora Theme 修改版。

来源：

```text
https://github.com/eamonxg/luci-theme-aurora
```

菜单位置：

```text
make menuconfig -> 39Wrt_Plugin -> luci-theme-aurora_mod
```

主要修改：

- 登录页默认使用 root 用户
- 隐藏用户名输入框
- 登录页只保留密码输入框
- 密码框 placeholder 显示为 `密码`
- 密码框 placeholder 居中
- 密码输入内容居中
- 登录页自动 focus 密码框
- 登录页 Logo 改为 `logo.gif`
- 去掉 Logo 原有外框、背景块、padding 和阴影
- Footer 显示为 `Powered by 39Wrt`
- `39Wrt` 带外链(固件更新下载网盘)

39Wrt 链接：

```text
http://pan.39network.cc:5212/s/gLtJ
```

登录页 Logo 路径：

```text
htdocs/luci-static/aurora/images/logo.gif
```

登录页 Footer 效果：

```text
© Aurora Theme Contributors · Powered by 39Wrt
```

后台 Footer 效果：

```text
Powered by 39Wrt
```

适配：

- OpenWrt 25
- LuCI openwrt-25.12
- 桌面端
- 移动端
- Safari / Chrome
- 多比例窗口

注意：

如果替换主题文件后页面没有变化，通常是 LuCI 缓存或浏览器缓存导致。

可在路由器执行：

```sh
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

浏览器建议强制刷新。

---

## 常用编译命令

编译完整固件：

```sh
make -j$(nproc) V=s
```

单独编译 39Wrt 默认设置包：

```sh
make package/39Wrt_Plugin/39Wrt_default-settings/compile V=s
```

单独编译 JDCloud CPE 配置包：

```sh
make package/39Wrt_Plugin/JDCloud_AX1800Pro_CPE/compile V=s
```

单独编译 5G Smart Case 插件：

```sh
make package/39Wrt_Plugin/5GSmartCase_ModSwitch/compile V=s
```

单独编译 AdGuard Home 插件：

```sh
make package/39Wrt_Plugin/luci-app-adguardhome/compile V=s
```

单独编译 Aurora 主题修改版：

```sh
make package/39Wrt_Plugin/luci-theme-aurora_mod/compile V=s
```

## 最小化 clean

清理单个插件：

```sh
make package/39Wrt_Plugin/<插件目录名>/clean
```

示例：

```sh
make package/39Wrt_Plugin/39Wrt_default-settings/clean
make package/39Wrt_Plugin/5GSmartCase_ModSwitch/clean
make package/39Wrt_Plugin/JDCloud_AX1800Pro_CPE/clean
make package/39Wrt_Plugin/luci-app-adguardhome/clean
make package/39Wrt_Plugin/luci-theme-aurora_mod/clean
```

重新生成 rootfs：

```sh
rm -rf build_dir/target-*/root-*
make target/install -j$(nproc) V=s
```

清理 LuCI 缓存：

```sh
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

## 注意事项

### uci-defaults 只在首次启动执行

`/etc/uci-defaults/` 下的脚本只会在首次启动或恢复出厂后执行。

如果设备已经启动过，再修改 defaults 包后需要：

- 重新刷机且不保留配置
- 或恢复出厂
- 或手动执行对应脚本

### IPv6 relay 适用条件

`JDCloud_AX1800Pro_CPE` 的 IPv6 relay 逻辑适用于上级只提供单 `/64` IPv6 且无 PD 的场景。

如果上级提供 PD，例如 `/56`、`/60` 或 `/64 PD`，应使用标准 IPv6 router/server 模式，而不是 relay 模式。

### ttyd root 自动登录风险

`39Wrt_default-settings` 默认将 ttyd 命令设置为：

```sh
/bin/login -f root
```

该配置适合内网调试和个人设备使用。

不建议将 ttyd 暴露到公网。

### ADB Shell 风险

`5GSmartCase_ModSwitch` 的 ADB Shell 可以执行设备端命令。

请确保 LuCI 账号安全，不要将管理页面暴露到公网。

### 主题缓存

修改 LuCI 主题后，如果页面没有变化，通常需要清理缓存：

```sh
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

浏览器侧也建议强制刷新或清理缓存。

## License

本仓库用于 39Wrt 插件整合与个人维护。

其中部分插件基于第三方开源项目修改，原项目版权归原作者所有。