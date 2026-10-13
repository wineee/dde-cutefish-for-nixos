# Go 服务包移植文档

> 状态：全部 Qt6 无关（Go 实现），版本最新。这些包产出 dbus service、
> systemd unit、polkit policy、gschema，**直接影响 NixOS 模块**。

## 概览

| 包 | 版本 | 产出 | 硬编码路径 | 模块影响 |
|---|---|---|---|---|
| dde-api | 6.0.48 | dbus service + systemd unit + polkit | `/usr/lib/deepin-api`（已批量替换）、Debian 工具（不改） | dde-api.nix 挂载 + 建 deepin-sound-player 用户 |
| dde-daemon | 6.1.108 | dbus service + systemd unit + udev | 大量 `/usr`（已批量替换） | dde-daemon.nix 挂载 + 建 deepin-daemon/admin 用户 |
| deepin-pw-check | 6.0.12 | dbus service + systemd unit + polkit | unit ExecStart（**已修复**） | deepin.nix 挂 dbus 但**未**挂 systemd.packages |
| deepin-desktop-schemas | 6.0.13 | gschema | gschema 默认壁纸路径（已替换） | deepin.nix systemPackages |
| startdde | 6.1.6 | systemd unit + lightdm.conf | tzdata（**已修复**） | deepin.nix systemPackages |

## 逐包说明

### dde-api
- D-Bus 接口（屏幕区域检测、缩略图、声音播放等）。
- **硬编码路径**：
  - `/usr/lib/deepin-api/*`（11 个 dbus service + systemd unit 的
    `Exec`/`ExecStart`）→ `/run/current-system/sw/lib/deepin-api`（模块
    `pathsToLink` 已链接）。当前用 `for file in $(grep ...)` 批量替换，
    工作正常。
  - Debian 专属工具：`/usr/bin/dpkg-query`、`/usr/bin/apt-cache`、
    `/usr/sbin/locale-gen`、`/usr/sbin/deepin-immutable-ctl`——NixOS 无这些
    工具，对应功能（包管理、locale 生成）本就不可用，**不改**。
  - `/usr/sbin/alsactl` → 裸 `alsactl`（走 PATH）。
- **产出**：dbus service（system + session）、systemd unit（device、
  locale-helper、login-sound、shutdown-sound、sound-theme-player）、
  polkit action。模块 `dde-api.nix` 挂 `systemd.packages` + `dbus.packages`，
  并建 `deepin-sound-player` 用户。

### dde-daemon
- 核心守护进程（账户、显示、输入设备、音频等）。
- **版本**：6.1.107 → 6.1.108（touchpad 扩展开关 + glib loop 修复）。
- **硬编码路径**：大量 `/usr`（accounts、inputdevices、grub2、zoneinfo 等），
  现有 postPatch 用 `find -exec sed` 批量替换到 `/run/current-system/sw` 或
  `$out`。工作正常，但批量替换方式不够精确（后续可优化为 patch 文件）。
- **产出**：大量 dbus service（system + session）、systemd unit（含 user
  unit）、udev 规则。模块 `dde-daemon.nix` 挂 `systemd.packages` +
  `dbus.packages` + `udev.packages`，并建 `deepin-daemon` /
  `deepin-admin-daemon` 用户（对应上游 sysusers）。

### deepin-pw-check
- 密码强度校验（PAM + cracklib）。
- **已修复 bug**：systemd unit `deepin-passwd-conf.service` 的
  `ExecStart=/usr/libexec/deepin-pw-check/deepin-pw-check` 硬编码（Makefile
  直接 cp，未做替换）→ 改为 `$out/libexec/...`。
- **产出**：dbus service（`org.deepin.dde.PasswdConf1`）+ systemd unit +
  polkit policy。模块 `deepin.nix` 挂了 `services.dbus.packages`（dbus service
  + conf + polkit 会被挂载），但**未**挂 `systemd.packages`——`deepin-passwd-conf.service`
  通过 dbus 的 `SystemdService=` 激活时，需要确认 unit 已挂载（**遗留**）。

### deepin-desktop-schemas
- GSettings schema 提供者（com.deepin.dde.* + com.deepin.wrap.gnome.*）。
- **硬编码路径**：gschema 默认值里的壁纸/背景 URI
  `file:///usr/share/backgrounds/...` → `/run/current-system/sw/share/backgrounds/...`
  （deepin-wallpapers 提供 `share/backgrounds`）。当前用 `for file in
  $(grep -rl "/usr/share")` 批量替换，会把 debian/rpm 构建文件也替换（无害）。
- **产出**：`share/gsettings-schemas/deepin-desktop-schemas-*/glib-2.0/schemas/`
  （NixOS gschema 标准位置，模块 systemPackages 挂载后由 glib 自动扫描）。

### startdde
- DDE 会话启动器（display 管理、色温等）。
- **已修复 bug**：`display/color_temp.go` 的 `timeZoneFile =
  "/usr/share/zoneinfo/zone1970.tab"` → `${tzdata}/share/zoneinfo/zone1970.tab`
  （新增 tzdata 依赖）。
- **硬编码路径**：`/usr/lib/deepin-daemon/dde-touchscreen-dialog`（postPatch
  已替换）、`/bin/bash`（已替换为 runtimeShell）、`/usr/bin/dbus-send`（已替换）。
- **产出**：systemd user unit（dde-display-task-refresh-brightness）+ lightdm.conf。
  模块 `deepin.nix` systemPackages 挂载。

## 模块影响清单

| 包 | systemd.packages | dbus.packages | udev.packages | 新建用户/组 |
|---|---|---|---|---|
| dde-api | ✅ dde-api.nix | ✅ dde-api.nix | — | deepin-sound-player |
| dde-daemon | ✅ dde-daemon.nix | ✅ dde-daemon.nix | ✅ dde-daemon.nix | deepin-daemon + deepin-admin-daemon |
| deepin-pw-check | ❌（仅 dbus.packages） | ✅ deepin.nix | — | — |
| deepin-desktop-schemas | —（gschema，无 unit） | — | — | — |
| startdde | —（user unit） | — | — | — |

## 已知遗留

1. **deepin-pw-check 的 systemd unit 未挂载**：模块只挂了
   `services.dbus.packages`，未挂 `systemd.packages`。若 dbus 激活
   `SystemdService=deepin-passwd-conf.service` 时 unit 不在，会失败。
   待 VM 验证密码校验功能时确认是否需要补挂。
2. **批量替换优化**：dde-api/dde-daemon/deepin-desktop-schemas 的
   `for ... grep`/`find -exec sed` 批量替换工作正常，但按质量规范应逐步
   改为 patch 文件（精确 diff，不误伤 debian/rpm 构建文件）。
3. **Debian 专属工具**：dde-api 的 dpkg/apt/locale-gen 功能在 NixOS 下
   不可用（无对应工具），当前不改，属于上游 Debian 生态功能。
