# dde-clipboard 移植文档

> 上游 `linuxdeepin/dde-clipboard` 6.1.36。可选的剪贴板管理器：一个常驻
> daemon + 一个 dde-dock / dde-shell 的托盘插件。

## 依赖链

```
qtbase qtdeclarative qtsvg qtwayland（+ wrapQtAppsHook）
dtkcore / dtkgui / dtkwidget
gio-qt
dde-shell / dde-tray-loader
wayland glib
kdePackages.extra-cmake-modules

← dde-session（autostart 拉起 daemon）
← dde-shell / dde-dock（加载 libdock-clipboard-plugin.so）
```

## 硬编码路径（postPatch）

| 文件 | 上游 | 改为 |
|---|---|---|
| `CMakeLists.txt` | `/etc/xdg/autostart` | `$out/etc/xdg/autostart` |
| `dock-clipboard-plugin/clipboardplugin.cpp` | `/usr/share/dde-clipboard/translations/dde-clipboard_` | `/run/current-system/sw/share/dde-clipboard/translations/dde-clipboard_` |

`/etc/xdg/autostart` 不在 `CMAKE_INSTALL_SYSCONFDIR` 覆盖范围内，必须显式点出。
插件翻译是按**绝对路径**拼出来的字符串，靠 `pathsToLink` 合并进系统 profile 才能读到。

## 编译输出（对 NixOS 模块的影响）

| 类型 | 路径 |
|---|---|
| CLI / daemon | `bin/dde-clipboard`、`bin/dde-clipboard-daemon` |
| 托盘插件 | `lib/dde-dock/plugins/libdock-clipboard-plugin.so` |
| 自动启动 | `etc/xdg/autostart/dde-clipboard.desktop` |
| systemd user unit | `lib/systemd/user/` |
| dbus session service | `share/dbus-1/services/` |
| 翻译 | `share/dde-clipboard/translations/` |
| 设置图标 | `share/dde-dock/icons/dcc-setting/{clipboard.svg,dcc-clipboard.dci}` |
| dconfig | `share/dsg/configs/` |
| 用户/组、polkit | 无 |

`pathsToLink` 需要 `/share/dde-clipboard`、`/share/dde-dock`（`/lib` 已由 nixpkgs
默认全量合并，`lib/dde-dock/plugins` 无需单列）。

## 已知遗留

- 无。
