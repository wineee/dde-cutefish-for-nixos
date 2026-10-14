# dde-session-ui 移植文档

> 上游 `linuxdeepin/dde-session-ui` 6.0.50。一组独立的 session 层 UI 小程序：
> CLI 对话框（hints / license / pixmix / wm-chooser / switchtogreeter）、
> 常驻 daemon（lowpower / bluetooth-dialog / suspend-dialog / touchscreen-dialog /
> warning-dialog / welcome / blackwidget）、以及一个 autostart 的登录提醒。

## 依赖链

```
qt6Packages（+ wrapQtAppsHook）、cmake / ninja / pkg-config
dtkcommon / dtkcore / dtkwidget
glib
xcbutilwm libxrandr xcrypt / deepin-pw-check
systemd
deepin-gettext-tools（构建期）
gtest

← dde-session / dde-session-shell / dde-control-center（拉起各对话框与 daemon）
```

## 硬编码路径（postPatch）

替换目标分三类，全部改成 `--replace-fail` 精确替换（旧实现是三段
`find … -exec sed`，对 `.cpp/.h` 统一把 `/usr/share`→sw、对
`.service/.desktop` 把 `/usr/bin|/usr/lib`→`$out`，行为随扩展名漂移、且
`systemd_USER_UNIT_DIR` 的替换串在 Nix 缩进字符串里有转义陷阱）：

**指向系统 profile（sw）—— 由其它包提供、经 pathsToLink 合并**

| 文件 | 上游 |
|---|---|
| 12 个 `*/main.cpp` + `deepin-login-reminder/main.cpp` | `/usr/share/dde-session-ui/translations` |
| `deepin-login-reminder/main.cpp` | `/usr/local/share/dde-session-ui/translations` |
| `widgets/fullscreenbackground.cpp` | `/usr/share/wallpapers/deepin/desktop.jpg`、`/usr/share/backgrounds/default_background.jpg` |
| `dde-blackwidget/src/window.cpp` | `/usr/share/deepin/uos_logo.svg`、`/usr/share/plymouth/themes/` |

**指向本包 `$out`**

| 文件 | 上游 |
|---|---|
| `dde-blackwidget/misc/systemd/user/dde-blackwidget{,-nodbus}.service` | `/usr/lib/deepin-daemon/dde-blackwidget` |
| `dde-warning-dialog/src/org.deepin.dde.WarningDialog1.service` | `/usr/lib/deepin-daemon/dde-warning-dialog` |
| `dde-welcome/src/org.deepin.dde.Welcome1.service` | `/usr/lib/deepin-daemon/dde-welcome` |
| `deepin-login-reminder/main.cpp` | `/usr/bin/dde-hints-dialog` |
| `deepin-login-reminder/deepin-login-reminder.desktop` | `/usr/bin/deepin-login-reminder` |

**安装路径**

- `deepin-login-reminder/CMakeLists.txt`：`/etc/xdg/autostart/` → `$out/etc/xdg/autostart/`
  （不在 `CMAKE_INSTALL_SYSCONFDIR` 覆盖范围内）。
- 顶层 `CMakeLists.txt`：注释掉
  `pkg_get_variable(SYSTEMD_USER_UNIT_DIR systemd systemd_user_unit_dir)`
  —— 否则 unit 会装回 systemd 自己的 store 路径；改用
  `-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user` 传入。

## 编译输出（对 NixOS 模块的影响）

| 类型 | 路径 |
|---|---|
| CLI | `bin/{dde-hints-dialog,dde-license-dialog,dde-pixmix,dde-switchtogreeter,dde-wm-chooser,deepin-login-reminder}` |
| daemon | `lib/deepin-daemon/{dde-lowpower,dde-bluetooth-dialog,dde-blackwidget,dde-warning-dialog,dde-welcome,dde-touchscreen-dialog,dde-suspend-dialog}` |
| 控制中心插件 | `lib/dde-control-center/reset-password-dialog` |
| systemd user unit | `lib/systemd/user/dde-blackwidget*.service` |
| 自动启动 | `etc/xdg/autostart/deepin-login-reminder.desktop` |
| dbus session service | `share/dbus-1/services/{BlackScreen1,WarningDialog1,Welcome1}.service` |
| 翻译 | `share/dde-session-ui/translations/` |
| 图标 / desktop | `share/icons/`、`share/applications/` |
| 用户/组、polkit | 无 |

`pathsToLink` 需要 `/share/dde-session-ui`；`share/icons`、`share/applications`、
`share/dbus-1` 由 NixOS 默认机制链接。

## 已知遗留

- `/usr/share/deepin/uos_logo.svg` 与 `/usr/share/plymouth/themes/` 改成 sw 路径后
  仍无提供方（本仓库没有任何包产出这两个文件），dde-blackwidget 的关机 logo /
  plymouth 主题显示会落空。等 artwork / plymouth 主题进仓库再补。
- `dde-blackwidget`、`dde-suspend-dialog` 等偏 X11 会话路径，wayland 下是否被拉起
  取决于会话图，未逐一验证。
