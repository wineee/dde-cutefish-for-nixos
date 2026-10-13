# 非 DTK 支撑库移植文档

> 状态：全部 Qt6、最新版本。这些库都是「纯库」——无 dbus service、
> systemd unit、gschema、polkit policy，不会影响 NixOS 模块的用户/服务创建。

## 概览

| 包 | 版本 | 来源 | 用途 | 备注 |
|---|---|---|---|---|
| deepin-pdfium | 1.5.8 | linuxdeepin | PDF 渲染（bundled pdfium） | .pc double-prefix 用 patch 修 |
| docparser | 1.0.26 | linuxdeepin | 全文搜索文档解析 | .pc double-prefix 用 patch 修；-pie 已 drop |
| gio-qt | 0.0.16 | linuxdeepin | GIO 的 Qt 封装 | 仅 qt6；CMAKE_INSTALL_LIBDIR=lib |
| gsettings-qt6 | 1.1.1 | nixpkgs lomiri-qt6.gsettings-qt | GSettings Qt6 绑定 | 原样复用 nixpkgs；下游自适配 |
| qt6mpris | 1.0.0.1-1deepin2 | deepin-community | MPRIS Qt6 绑定 | qmake；路径已 patch |
| treeland-protocols | 0.7.0 | linuxdeepin | Wayland 协议 XML | 纯协议文件 |
| udisks2-qt6 | 6.0.1 | linuxdeepin | UDisks2 D-Bus Qt6 绑定 | .pc double-prefix 用 patch 修 |
| util-dfm | 1.4.5 | linuxdeepin | 文件管理器底层库 | .pc 用 _FULL_ 路径，正确 |
| dde-seatd | 0.9.3-3 | linuxdeepin | seatd 服务 | 见 core 文档 |

## 逐库说明

### deepin-pdfium
- bundled pdfium（`src/3rdparty/pdfium`），编译慢但无需外部 pdfium。
- **硬编码路径**：bundled pdfium `fx_ge_linux.cpp` 的字体 fallback 路径
  `/usr/share/fonts`、`/usr/share/X11/fonts/*`、`/usr/local/share/fonts`——
  这是 pdfium 无 fontconfig 时的兜底扫描；Qt 层通常已通过 fontconfig 提供字体，
  宿主 Deepin 也是这些路径，**不改**。
- `.pc`：`fix-pc-double-prefix.patch` 把 `${prefix}/@CMAKE_INSTALL_LIBDIR@` →
  `@CMAKE_INSTALL_FULL_LIBDIR@`（同 INCLUDEDIR）。
- `Config.cmake` 用 `PACKAGE_PREFIX_DIR` 相对定位 + `pkg_check_modules`
  （libopenjp2/lcms2/freetype2/zlib/libpng/libjpeg），正确。

### docparser
- **-pie**：CMake >= 4 下 `add_link_options(-pie)` 破坏 shared lib 链接，
  postPatch 已 drop（`-z noexecstack -pie -fPIC` → `-z noexecstack -fPIC`）。
- `.pc`：`fix-pc-double-prefix.patch` 改为 `_FULL_` 变量（同上）。

### gio-qt
- 上游同时构建 qt5/qt6；我们 `postPatch` 去掉 `include(qt5.cmake)`（qt5 不在 scope）。
- `-DCMAKE_INSTALL_LIBDIR=lib`（相对路径），`.pc` 无 double-prefix。
- 仅 qt6 库 `libgio-qt6.so` + `gio-qt6.pc`。

### gsettings-qt6
- **原样复用 nixpkgs 的 `lomiri-qt6.gsettings-qt`**（不 fork、不 override）。
- nixpkgs 版 `.pc` 只提供 `-I.../include/qt6/QGSettings`，即只支持
  `#include <QGSettings>` 风格；deepin 下游用 `#include <QGSettings/QGSettings>`
  的包需在包内 postPatch 自行改标准风格：
  - **dde-appearance**：`themes.cpp` 里 `#include <QGSettings/QGSettings>` →
    `#include <QGSettings>`（已在包内 postPatch 处理）。
  - **dtkcore**：`gsettingsbackend.cpp` 已用 `QT_HAS_INCLUDE` 自适应，无需改。
- QML 模块装到 `$out/qt6/qml/GSettings.1.0`（nixpkgs 已处理版本化模块名）。

### qt6mpris
- 来源 **deepin-community/qt6mpris**（qmake 项目），非 linuxdeepin。
- `postPatch` 把 qmake 变量（`$$[QT_INSTALL_LIBS]` 等）替换为 `$out` 绝对路径。
- 无 FHS 路径问题（qmake 项目已全量重定向）。

### treeland-protocols
- 纯 Wayland 协议 XML（treeland 私有协议），无代码、无路径。
- 上游最新 0.7.0，与 treeland 0.11.0 配套。

### udisks2-qt6
- UDisks2 D-Bus 接口的 Qt6 绑定（生成 dbus 接口代码，无 dbus service 文件）。
- `.pc`：`fix-pc-double-prefix.patch` 把 `${prefix}/@CMAKE_INSTALL_LIBDIR@` →
  `@CMAKE_INSTALL_FULL_LIBDIR@`（同 INCLUDEDIR），避免 nixpkgs 传绝对路径时
  double-prefix。
- `Config.cmake` 正确（`find_dependency(Qt6 Core DBus)` + PACKAGE_PREFIX_DIR）。

### util-dfm
- 文件管理器底层库（dfm-io/mount/burn/search），多个 `.pc` 已用
  `CMAKE_INSTALL_FULL_*`（绝对路径），无 double-prefix。
- **硬编码路径**：
  - `/etc/fstab`（`dfmio_utils.cpp`）——标准系统文件，NixOS 兼容，不改。
  - `/etc/samba/smb.conf`（`dnetworkmounter.cpp`）——Samba 标准配置，不改。

## 通用结论

这些非 DTK 支撑库质量较高，主要坑点都已在定义中处理：

1. **double-prefix**：udisks2-qt6 / deepin-pdfium / docparser 均用
   `fix-pc-double-prefix.patch` 改为 `_FULL_` 变量；gio-qt 通过相对
   `CMAKE_INSTALL_LIBDIR=lib` 规避；util-dfm 上游直接用 `_FULL_` 变量
   （无需任何 patch）；gsettings-qt6 原样复用 nixpkgs 已处理。
2. **-pie**：docparser 已 drop（CMake 4.x shared lib 链接失败）。
3. **Qt5/Qt6 混建**：gio-qt 移除 qt5.cmake。
4. **qmake 路径**：qt6mpris 全量重定向 `$$[QT_INSTALL_*]`。
5. **FHS 路径**：仅 deepin-pdfium 字体 fallback、util-dfm 的 `/etc/fstab`/
   `/etc/samba/smb.conf`——均为标准路径或 fontconfig 兜底，不改。

无任何包产生 dbus service / systemd unit / gschema / polkit policy，
不会影响 NixOS 模块的用户、服务、配置。
