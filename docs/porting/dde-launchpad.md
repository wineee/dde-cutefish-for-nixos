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

### 不需要重定向，也不需要 on-disk qmldir

applet 通过 `ds_install_package` 装到 dde-shell 导出的
`DDE_SHELL_{PLUGIN,PACKAGE,TRANSLATION}_INSTALL_DIR`。dde-shell 2.0.57 的
`DDEShellConfig.cmake.in` 原本用 `@CMAKE_INSTALL_PREFIX@/...` 拼成绝对路径，
指向 dde-shell 自己的 store；该模板已在 dde-shell 侧只去掉前缀、保留上游算出的
相对值，于是 `ds_install_package` 自然落到**本包自己的 prefix**，本包不需要重定向
（原先那两条 sed 已删，见 development.md 升级日志）。

Qt 的 QML 目录那条 `find` 也一并删了。2026-10-15 实测它在 2.0.49 上是 no-op：
三个 QML 模块都以 resource 形式嵌在 `launchpadcommon.so` 的 `/qt/qml/…` 下，
Qt 默认的 `qrc:/qt/qml` 导入路径就能找到，构建系统里根本没有往
`${qtbase}/lib/qt-6/qml` 安装的规则，所以 `find` 匹配不到任何东西。删掉后重建，
产物文件清单与删之前逐条相同（76 个文件）。

而且原重定向的目标 `$out/lib/qt6/qml` 本身也不在任何导入路径上（本包没有
`bin/`、没有 wrapper，`pathsToLink` 也不含它），即使真有规则命中，装过去也是无效的。

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
