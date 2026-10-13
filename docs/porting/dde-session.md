# dde-session 移植文档

> 版本：2.0.34 ｜ 仓库：linuxdeepin/dde-session ｜ 许可：GPL-3+
> 角色：会话管理器（systemd user session 图 + D-Bus `org.deepin.dde.Session1`）

## 依赖链

```
dtkcore dtkcommon glib libsecret systemd libx11 libxcb libxcursor libxfixes libcap-ng
  + dde-shell / dde-application-manager / dde-polkit-agent / dde-session-shell
  + gnome-keyring（运行时 exec）
```

## 硬编码路径检查

源码里 `/usr` 分两类：**编译进二进制的**（必须改）和 **shell/unit 里的**
（运行时解析）。

### 编译进二进制（sessionmanager.cpp 等）

| 原值 | 替换 | 理由 |
|---|---|---|
| `/usr/bin/dde-lock` | `${dde-session-shell}/bin/dde-lock` | `SetLocked()` 校验调用方 cmdline，不改会误判为非法调用方 |
| `/usr/libexec/deepin/dde-lock` | `${dde-session-shell}/libexec/deepin/dde-lock` | 同上，另一个候选路径 |
| `/usr/bin/dde-am` | `${dde-application-manager}/bin/dde-am` | 强制关机分支 |
| `/usr/libexec/dde-session-ctl` | `$out/libexec/dde-session-ctl` | 本包产出 |
| `/usr/lib/deepin-daemon/langselector` | `/run/current-system/sw/lib/deepin-daemon/langselector` | dde-daemon 提供；`/lib` 由 nixpkgs 默认 pathsToLink 合并 |
| `/usr/bin/systemd-detect-virt` | `${systemd}/bin/systemd-detect-virt` | 虚拟机检测 |
| `/usr/lib/deepin-daemon/dde-welcome`（version-checker） | sw 路径 | 同上 |
| `/usr/bin/dde-lock`（quick-login） | `${dde-session-shell}/bin/dde-lock` | 快速登录拉起锁屏 |

### Shell / unit / desktop 文件

`misc/Xsession.d/*`、`tools/dde-oom-score-adj/dde-oom-score-adj.desktop`、
`misc/dde-session-loader-wrapper.in`、各 `.service`/`.service.in`、
`dbus/org.deepin.dde.Session1.service` 全部改为 store 绝对路径。

`dde-session-loader-wrapper.in` 的 `PATH=/usr/sbin:/usr/bin:/sbin:/bin` 改为
`/run/current-system/sw/bin` —— 否则脚本里的 `logger` 找不到（即使 fallback
分支也要用 `log_to_journal`）。

### CMake 安装目标

`misc/CMakeLists.txt` 与 `tools/dde-oom-score-adj/CMakeLists.txt` 用**绝对值**
`DESTINATION /etc/...`，`-DCMAKE_INSTALL_SYSCONFDIR` 对它们无效，单独替换成
`$out/etc/...`。

### 刻意不改

- `/usr/bin/deepin-security-loader{,-exec}`：包在 `[ -x ... ]` 判断里，
  NixOS 上没有就走 fallback 直接启动 `dde-session`，无需 patch。
- `/usr/bin/deepin-keyring-whitebox`：同样是 `[ -x ]` 守卫，未打包即跳过。
- `/usr/bin/kwin_x11`：X11 会话 unit 的 `ExecStart`，改成注释。该 unit 带
  `ConditionEnvironment=XDG_SESSION_TYPE=%I`，Wayland 下本来就不激活。

## 编译输出（对 NixOS 模块的影响）

| 类型 | 数量 | 说明 |
|---|---|---|
| systemd user unit | 23（+`lib/systemd/user` 是 `share/systemd/user` 的符号链接） | 需要在 `systemd.packages` 里挂载，`deepin.nix` 已含 |
| D-Bus session service | 1（`org.deepin.dde.Session1.service`） | `services.dbus.packages` 已含 |
| dconfig | 1 | — |
| `/etc/X11/Xsession.d` | 3 | 装进 `$out/etc`，NixOS 不会自动并入 `/etc`，X11 会话才用 |
| `/etc/xdg/autostart` | 1 | 同上 |
| `/etc/profile.d` | 1 | 同上 |
| xsessions | 1 | 需在 `environment.pathsToLink` 加 `/share/xsessions` |
| gschema / polkit / 用户 | 无 | — |

`passthru.providedSessions = [ "deepin" ]` 供 display manager 识别。

## 已知遗留

- X11 会话路径（`Xsession.d`、`dde-session@x11.service`）在当前 treeland/Wayland
  目标下基本用不到，仅做路径修正，未验证运行时。
- `ExecStartPre` 里 `cp -n /etc/xdg/kglobalshortcutsrc` 带 `-` 前缀（失败可忽略），
  未改。
