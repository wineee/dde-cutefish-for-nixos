# 非 DTK 支撑库移植文档

> 状态：全部 Qt6、最新版本。这些库都是「纯库」——无 dbus service、
> systemd unit、gschema、polkit policy，不会影响 NixOS 模块的用户/服务创建。

## 概览

| 包 | 版本 | 来源 | 用途 | 备注 |
|---|---|---|---|---|
| deepin-pdfium | 1.5.8 | linuxdeepin | PDF 渲染（bundled pdfium） | .pc double-prefix 已处理 |
| docparser | 1.0.26 | linuxdeepin | 全文搜索文档解析 | .pc double-prefix 已处理；-pie 已 drop |
| gio-qt | 0.0.16 | linuxdeepin | GIO 的 Qt 封装 | 仅 qt6；CMAKE_INSTALL_LIBDIR=lib |
| gsettings-qt6 | 1.1.1 | ubports(GitLab) | GSettings Qt6 绑定 | 非 linuxdeepin；lomiri cmake-extras |
| qt6integration | 6.0.50 | linuxdeepin | Qt 平台主题插件 | 无 FHS 路径 |
| qt6mpris | 1.0.0.1-1deepin2 | deepin-community | MPRIS Qt6 绑定 | qmake；路径已 patch |
| qt6platform-plugins | 6.0.50 | linuxdeepin | Qt 平台插件（xcb） | 解包 qtbase xcb 私有头 |
| treeland-protocols | 0.7.0 | linuxdeepin | Wayland 协议 XML | 纯协议文件 |
| udisks2-qt6 | 6.0.1 | linuxdeepin | UDisks2 D-Bus Qt6 绑定 | .pc double-prefix 已处理 |
| util-dfm | 1.4.5 | linuxdeepin | 文件管理器底层库 | .pc 用 _FULL_ 路径，正确 |
| dde-seatd | 0.9.3-3 | linuxdeepin | seatd 服务 | 见 core 文档 |

## 逐库说明

### deepin-pdfium
- bundled pdfium（`src/3rdparty/pdfium`），编译慢但无需外部 pdfium。
- **硬编码路径**：bundled pdfium `fx_ge_linux.cpp` 的字体 fallback 路径
  `/usr/share/fonts`、`/usr/share/X11/fonts/*`、`/usr/local/share/fonts`——
  这是 pdfium 无 fontconfig 时的兜底扫描；Qt 层通常已通过 fontconfig 提供字体，
  宿主 Deepin 也是这些路径，**不改**。
- `.pc`：postInstall `sed s|${prefix}/|/|g` 修 double-prefix；产物为
  `${prefix}//lib`（双斜杠无害，pkg-config/链接器都接受）。
- `Config.cmake` 用 `PACKAGE_PREFIX_DIR` 相对定位 + `pkg_check_modules`
  （libopenjp2/lcms2/freetype2/zlib/libpng/libjpeg），正确。

### docparser
- **-pie**：CMake >= 4 下 `add_link_options(-pie)` 破坏 shared lib 链接，
  postPatch 已 drop（`-z noexecstack -pie -fPIC` → `-z noexecstack -fPIC`）。
- `.pc`：postInstall 修 double-prefix（同上）。

### gio-qt
- 上游同时构建 qt5/qt6；我们 `postPatch` 去掉 `include(qt5.cmake)`（qt5 不在 scope）。
- `-DCMAKE_INSTALL_LIBDIR=lib`（相对路径），`.pc` 无 double-prefix。
- 仅 qt6 库 `libgio-qt6.so` + `gio-qt6.pc`。

### gsettings-qt6
- 来源 **GitLab ubports/development/core/gsettings-qt**，非 linuxdeepin。
- Qt6 构建，需 `lomiri.cmake-extras`。
- **postPatch**（4 处）：
  1. `WERROR` → `ENABLE_WERROR`（上游改名遗漏）
  2. `.pc` libdir/includedir 修 double-prefix
  3. `Cflags` 加 `@QT_FULL_INCLUDE_DIR@`（支持 `#include <QGSettings/...>` 风格）
  4. QML 模块装到标准 qt6/qml 路径
- **postInstall**：QML 模块重命名 `GSettings` → `GSettings.1.0`（版本化模块名）。

### qt6integration
- Qt 平台主题插件（chameleon 风格等），装到 `$out/${qtbase.qtPluginPrefix}`。
- `DTK_VERSION` 是**自身项目版本**（非 DTK 版本），传 `finalAttrs.version` 正确
  （上游 archlinux PKGBUILD 同款）。
- 无硬编码 FHS 路径。

### qt6mpris
- 来源 **deepin-community/qt6mpris**（qmake 项目），非 linuxdeepin。
- `postPatch` 把 qmake 变量（`$$[QT_INSTALL_LIBS]` 等）替换为 `$out` 绝对路径。
- 无 FHS 路径问题（qmake 项目已全量重定向）。

### qt6platform-plugins
- Qt 平台插件（xcb），需 qtbase 私有头：`postUnpack` 从 `qtbase.src` 解包
  `src/plugins/platforms/xcb` 到 `xcb/libqt6xcbqpa-dev/${version}`。
- `DTK_VERSION` 同样是自身版本；`DTK_VERSION_MAJOR` 源码硬编码 "6"。
- 无硬编码 FHS 路径。

### treeland-protocols
- 纯 Wayland 协议 XML（treeland 私有协议），无代码、无路径。
- 上游最新 0.7.0，与 treeland 0.11.0 配套。

### udisks2-qt6
- UDisks2 D-Bus 接口的 Qt6 绑定（生成 dbus 接口代码，无 dbus service 文件）。
- `.pc`：postInstall 修 double-prefix。
- `Config.cmake` 正确（`find_dependency(Qt6 Core DBus)` + PACKAGE_PREFIX_DIR）。

### util-dfm
- 文件管理器底层库（dfm-io/mount/burn/search），多个 `.pc` 已用
  `CMAKE_INSTALL_FULL_*`（绝对路径），无 double-prefix。
- **硬编码路径**：
  - `/etc/fstab`（`dfmio_utils.cpp`）——标准系统文件，NixOS 兼容，不改。
  - `/etc/samba/smb.conf`（`dnetworkmounter.cpp`）——Samba 标准配置，不改。

## 通用结论

这些非 DTK 支撑库质量较高，主要坑点都已在定义中处理：

1. **double-prefix**：docparser / udisks2-qt6 / deepin-pdfium / gsettings-qt6
   通过 postInstall/postPatch sed 修复；gio-qt 通过相对 `CMAKE_INSTALL_LIBDIR=lib`
   规避；util-dfm 上游直接用 `_FULL_` 变量。
2. **-pie**：docparser 已 drop（CMake 4.x shared lib 链接失败）。
3. **Qt5/Qt6 混建**：gio-qt 移除 qt5.cmake。
4. **qmake 路径**：qt6mpris 全量重定向 `$$[QT_INSTALL_*]`。
5. **FHS 路径**：仅 deepin-pdfium 字体 fallback、util-dfm 的 `/etc/fstab`/
   `/etc/samba/smb.conf`——均为标准路径或 fontconfig 兜底，不改。

无任何包产生 dbus service / systemd unit / gschema / polkit policy，
不会影响 NixOS 模块的用户、服务、配置。
