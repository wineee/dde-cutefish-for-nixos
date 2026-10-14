# dde-launchpad 移植文档

> 上游 `linuxdeepin/dde-launchpad` 2.0.49。dde-shell 的**启动器 dock applet**
> （QML + C++ 插件），不是独立进程。

## 依赖链

```
qtbase qtdeclarative qtsvg qtwayland qt5compat（+ wrapQtAppsHook）
dtkcommon / dtkcore / dtkgui / dtkdeclarative
glib systemd appstream kdePackages.appstream-qt
dde-shell                    # applet 宿主，插件装进它的 lib/share
dde-application-manager      # 启动应用

← dde-shell（加载 org.deepin.ds.dock.launcherapplet）
```

## 改动要点

### postPatch：日志配置里的 dde-shell 路径

`dist/deepin-log-config/org.deepin.dde.launchpad.json` 的 `/usr/bin/dde-shell`
改指 `${dde-shell}/bin/dde-shell`。该文件由 **deepin-log-viewer**（不在本仓库）
读取，用来把日志过滤项映射到进程。

### postConfigure：安装路径重定向

applet 的安装目标默认落在 `dde-shell` 的 store 路径里，会污染依赖包；改用
`cmake_install.cmake` 重写：

- `${dde-shell}/share/dde-shell` → `$out/share/dde-shell`
- `${dde-shell}/lib/dde-shell` → `$out/lib/dde-shell`
- `${qtbase}/lib/qt-6/qml` → `$out/lib/qt6/qml`（Qt QML 默认目录是 qtbase 的只读路径）

### 不需要 on-disk qmldir

三个 QML 模块都以 resource 形式嵌在 `launchpadcommon.so` 的 `/qt/qml/…` 下，
Qt 默认的 `qrc:/qt/qml` 导入路径能找到。`$out/lib/qt6/qml` 本身不在任何导入路径上
（本包没有 `bin/`、没有 wrapper，`pathsToLink` 也不含它），手写 qmldir 是无效的。

## 编译输出（对 NixOS 模块的影响）

| 类型 | 路径 |
|---|---|
| applet 插件 | `lib/dde-shell/org.deepin.ds.dock.launcherapplet.so` |
| 公共库 | `lib/launchpadcommon.so` |
| applet 资源 / 图标 / 翻译 | `share/dde-shell/org.deepin.ds.dock.launcherapplet/{metadata.json,launcheritem.qml,icons/,translations/}` |
| dconfig | `share/dsg/configs/dde-launchpad`、`share/dsg/configs/org.deepin.dde.shell` |
| 日志/调试配置 | `share/deepin-log-viewer/deepin-log.conf.d/`、`share/deepin-debug-config/deepin-debug-config.d/` |
| AppStream | `share/metainfo/` |
| bin、systemd、dbus、用户/组 | 无 |

`pathsToLink` 需要 `/share/dde-shell`、`/share/dsg`。

## 已知遗留

- `share/deepin-log-viewer/` 与 `share/deepin-debug-config/` 未进 `pathsToLink`：
  消费方 deepin-log-viewer / deepin-debug-config 都不在本仓库，等它们进来时再补。
- `lib/launchpadcommon.so` 直接放在 `lib/` 顶层（不是子目录）。`/lib` 已由 nixpkgs
  默认全量合并，无需处理。
