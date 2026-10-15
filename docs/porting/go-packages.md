# Go 服务包移植文档

> 状态：全部 Qt6 无关（Go 实现），版本最新。这些包产出 dbus service、
> systemd unit、polkit policy、gschema，**直接影响 NixOS 模块**。

## 概览

| 包 | 版本 | 产出 | 硬编码路径 | 模块影响 |
|---|---|---|---|---|
| dde-api | 6.0.48 | dbus service + systemd unit + polkit | `/usr/lib/deepin-api`（已精确替换）、Debian 工具（不改） | dde-api.nix 挂载 + 建 deepin-sound-player 用户 |
| dde-daemon | 6.1.108 | dbus service + systemd unit | 大量 `/usr`（已 patch + 精确替换） | dde-daemon.nix 挂载 + 建 deepin-daemon/admin 用户 |
| deepin-pw-check | 6.0.12 | dbus service + systemd unit + polkit | unit ExecStart（**已修复**） | deepin.nix 挂 dbus + systemd.packages |
| deepin-desktop-schemas | 6.0.13 | gschema | gschema 默认壁纸路径（已精确替换） | deepin.nix systemPackages |
| startdde | 6.1.6 | systemd unit + lightdm.conf | tzdata（**已修复**） | deepin.nix systemPackages |

## 逐包说明

### dde-api
- D-Bus 接口（屏幕区域检测、缩略图、声音播放等）。
- **硬编码路径**：
  - `/usr/lib/deepin-api/*`（11 个 dbus service + systemd unit 的
    `Exec`/`ExecStart`）→ `/run/current-system/sw/lib/deepin-api`（模块
    `pathsToLink` 已链接）。postPatch 明确列出这 11 个被 Makefile 安装的
    文件逐个 `substituteInPlace --replace-fail`；`debian/dde-api.postinst`
    不安装，有意保留。
  - Debian 专属工具：`/usr/bin/dpkg-query`、`/usr/bin/apt-cache`、
    `/usr/sbin/locale-gen`、`/usr/sbin/deepin-immutable-ctl`——NixOS 无这些
    工具，对应功能（包管理、locale 生成）本就不可用，**不改**。
  - `/usr/sbin/alsactl` → 裸 `alsactl`（走 PATH）。
  - `/usr/share/dde-api`（`adjust-grub-theme/main.go` +
    `language_support/lang_support.go`）→ `$out/share/dde-api`（Makefile
    installs misc/data）。
- **产出**：dbus service（system + session）、systemd unit（device、
  locale-helper、login-sound、shutdown-sound、sound-theme-player）、
  polkit action。模块 `dde-api.nix` 挂 `systemd.packages` + `dbus.packages`，
  并建 `deepin-sound-player` 用户。

### dde-daemon
- 核心守护进程（账户、显示、输入设备、音频等）。
- **版本**：6.1.107 → 6.1.108（touchpad 扩展开关 + glib loop 修复）。
- **硬编码路径**：大量 `/usr`（accounts、inputdevices、grub2、zoneinfo 等），
  postPatch 已按 f81b263 基准重构：`0001-dont-set-PATH.patch` 删两处
  `os.Setenv("PATH")`（原 sed 只删单行，导致 main.go 的 `if err != nil`
  检查的是外层残留 err，语义错误），其余逐文件
  `substituteInPlace --replace-fail`。并补了基准也遗漏的两处：
  `accounts1/user.go` 的 `deepinThemePath`（`/usr/share/deepin-themes/`）和
  `getSessionList` 的 `/usr/share/xsessions` → `/run/current-system/sw/share`。
- **基线另两个 patch（0002/0003）确认失效、不再恢复**（2026-10-15 对照
  6.1.108 源码逐项核实）：0002 的 custom-wallpapers 目录上游已改为
  `/var/cache/wallpapers/`、`head` 调用已移除；0003 的 7 处目标代码
  （controlCenterPath 精确比较、chpwd 的 exe 白名单、dde-authority 目录、
  grub2.go 控制中心路径、powerbtn.sh、80-deepin-fprintd.rules、
  displaycfg.go 的 greeter 比较）在 6.1.107+ 均已删除或改为 uid 校验。
  bc8dae9 升级时以 "drop stale diffs" 删除属正确决定，勿重新加回。
- **产出**：大量 dbus service（system + session）、systemd unit（含 user
  unit）。6.1.107 起上游不再装 udev 规则（Makefile 无 udev 安装规则），
  模块 `dde-daemon.nix` 里的 `services.udev.packages` 是死配置，已于
  2026-10-15 删除。模块另挂 `systemd.packages` + `dbus.packages`，并建
  `deepin-daemon` / `deepin-admin-daemon` 用户（对应上游 sysusers）。
- **已修复 bug（2026-10-15，按产物逐个核对）**：Makefile 把二进制装进
  `$out/lib/deepin-daemon`、`$out/libexec/deepin`，但一批随包安装的
  service/unit/脚本仍写死 `/usr/lib/deepin-daemon`、`/usr/libexec/deepin`，
  在 NixOS 上必然失败。已在 postPatch 用 `--replace-fail` 精确修正 21 处：
  - 11 个 session dbus service（Audio1/Bluetooth1/InputDevices1/
    LangSelector1/LastoreSessionHelper1/Search1/SessionWatcher1/SystemInfo1/
    Timedate1/XEventMonitor1/Zone1）的 `Exec=` → `/run/current-system/sw/lib/deepin-daemon`；
  - 5 个 system unit + 2 个 user unit（含 `org.dde.session.Daemon1.service`
    的 `ExecStart`）的 `ExecStart=` → 同上；
  - `dde-session-daemon-loader-wrapper` / `langselector-loader-wrapper` 的
    `REAL_BINARY` → `$out/libexec/deepin`（这个最隐蔽：wrapper 自身能起来，
    但 exec 的目标不存在）；
  - `system_actions.json` 里 terminal/lockScreen/fileManager 三个快捷键
    Action（Go 侧 `system_shortcut.go` 只读这个 JSON，不读源码常量）；
  - `lightdm.conf` 的 `session-cleanup-script`。
- **确认无碍的残留**：产物里仍含 `/usr` 的位置都不是 bug —— 沙箱用的
  `ReadWritePaths=-/usr/...`（`-` 前缀容忍缺失）、被注释掉的行、
  `scheduler/config.json`（上游 `BUILD_TAGS ?= noscheduler` 默认禁用该模块，
  永不读取）、`cameraSwitch.sh` 的 deepin-camera desktop（该脚本对应
  `cmdCamera` 常量已是死代码，未编进二进制）、`deepin-camera` 包本就 removed。
  `touchscreen.json` 的 `longpressBlacklist` 是 DConfig 运行时可改的偏好，
  非硬编码路径，未动。

### deepin-pw-check
- 密码强度校验（PAM + cracklib）。
- **已修复 bug**：systemd unit `deepin-passwd-conf.service` 的
  `ExecStart=/usr/libexec/deepin-pw-check/deepin-pw-check` 硬编码（Makefile
  直接 cp，未做替换）→ 改为 `$out/libexec/...`。
- **产出**：dbus service（`org.deepin.dde.PasswdConf1`）+ systemd unit +
  polkit policy。模块 `deepin.nix` 同时挂 `services.dbus.packages` 和
  `systemd.packages`（`deepin-passwd-conf.service` 通过 dbus 的
  `SystemdService=` 激活，unit 必须在 systemd 搜索路径）。

### deepin-desktop-schemas
- GSettings schema 提供者（com.deepin.dde.* + com.deepin.wrap.gnome.*）。
- **硬编码路径**：gschema 默认值里的壁纸/背景 URI
  `file:///usr/share/backgrounds/...` → `/run/current-system/sw/share/backgrounds/...`
  （deepin-wallpapers 提供 `share/backgrounds`）。postPatch 明确列出 7 个
  `schemas/` + `overrides/` 源文件（build 阶段复制到 result/ 并安装），
  不再用 `grep -rl` 误伤 debian/rpm/archlinux 打包目录。
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
| dde-daemon | ✅ dde-daemon.nix | ✅ dde-daemon.nix | —（上游 6.1.107 起不再产出 udev 规则） | deepin-daemon + deepin-admin-daemon |
| deepin-pw-check | ✅ deepin.nix | ✅ deepin.nix | — | — |
| deepin-desktop-schemas | —（gschema，无 unit） | — | — | — |
| startdde | —（user unit） | — | — | — |

## 已知遗留

1. **Debian 专属工具**：dde-api 的 dpkg/apt/locale-gen 功能在 NixOS 下
   不可用（无对应工具），当前不改，属于上游 Debian 生态功能。
2. **dde-api 的 `debian/dde-api.postinst`**：含 `/usr/lib/deepin-api` 和
   `/usr/share/dde-api` 硬编码，但不被 Makefile 安装（属于 Debian 打包），
   有意保留不替换。
