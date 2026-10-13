# DTK 库移植文档

> 状态：全部 Qt6、最新版本（6.7.50 / dtksystemsettings 6.6.22）。
> 命名约定：DTK 库「去 6 后缀」（`dtkcore`/`dtkgui`/`dtkwidget`/`dtkdeclarative`/
> `dtksystemsettings`/`dtklog`），区别于参考项目 `dtk6*` 命名。

## 概览

| 包 | 版本 | Qt | 依赖链 | 备注 |
|---|---|---|---|---|
| dtkcommon | 6.7.50 | 无 | — | 纯 cmake，提供 DSG 配置 json |
| dtklog | 6.7.50 | Qt6 | qtbase + spdlog + systemd(可选) | 日志库 |
| dtkcore | 6.7.50 | Qt6 | dtkcommon + dtklog + lshw + libuchardet | 核心库，提供 Dtk6Core/Dtk6Tools/Dtk6DConfig cmake |
| dtkgui | 6.7.50 | Qt6 | dtkcore + librsvg | GUI 基础，提供 Dtk6Gui cmake |
| dtkwidget | 6.7.50 | Qt6 | dtkgui + cups + libstartup_notification | 控件库，提供 Dtk6Widget cmake |
| dtkdeclarative | 6.7.50 | Qt6 | dtkgui + qtdeclarative + qtshadertools + qt5compat | QML 扩展 |
| dtksystemsettings | 6.6.22 | Qt6 | dtkcore + libxcrypt | 系统设置辅助 |

## 通用约定

所有 DTK 库：

- `cmakeFlags` 带 `-DDTK5=OFF`（只建 Qt6 分支，产出 `libdtk6*.so` + `Dtk6*Config.cmake`）
- `dontWrapQtApps = true`（除 dtkcore/dtkgui/dtkwidget 有 libexec 工具需 wrap）
- `fix-pkgconfig-path.patch` / `fix-pri-path.patch`：nixpkgs 传 `CMAKE_INSTALL_LIBDIR`/
  `INCLUDE_INSTALL_DIR`/`TOOL_INSTALL_DIR` 为绝对路径时，去掉 `.pc`/`.pri` 里的
  `${prefix}/` 双重前缀
- `preConfigure` 显式 `QT_PLUGIN_PATH`（避免 `qt.qpa.plugin: minimal` 找不到）

## 逐库说明

### dtkcommon
- 无 Qt、无编译。`cmake` 把 `share/dsg/configs/org.deepin.dtk.preference.json`
  装到 `$out/share/dsg/configs/`。
- 该 json 被 dtkgui 在**编译期**通过 `dtk_add_config_to_cpp` 嵌入 C++ 头，故
  dtkgui 依赖 dtkcommon 的路径（见 dtkgui 的 postPatch）。

### dtklog
- `spdlog` + `systemd`（`withSystemd` 可选，默认跟随平台可用性）。
- 无 gsettings/dbus/systemd unit。

### dtkcore
- **输出**：`out` + `dev`。`libexec/dtk6/DCore/bin/*`（`dconfig2cpp`、
  `dtk-settings`、`deepin-svg` 等）需 `wrapQtApp`。
- **cmake 模块**：提供 `Dtk6CoreConfig.cmake`、`Dtk6ToolsConfig.cmake`、
  `Dtk6DConfigConfig.cmake`（dconfig2cpp 集成）、`Dtk6CMakeConfig.cmake`。
  上层 `find_package(Dtk6 COMPONENTS Core)` 会级联 `find_dependency(Dtk6DConfig)`
  / `Dtk6Log`——这些都由本包自身提供，无需额外依赖。
- **postPatch**：`DtkCoreConfig.cmake.in` 里 `PACKAGE_TOOL_INSTALL_DIR` 替换为
  `$out/libexec/dtk6/DCore/bin`（否则下游拿到的是构建机绝对路径）。
- **DSG 前缀**：`-DDSG_PREFIX_PATH=/run/current-system/sw`（DSG appdata 运行时
  查找路径）；`-DD_DSG_APP_DATA_FALLBACK=/var/dsg/appdata`（数据兜底）。
- **硬编码路径检查**：
  - `src/dsysinfo.cpp` 读 `/etc/os-release`（NixOS 存在，正常）；fallback
    `/usr/lib/os-release` 仅在找不到 `/etc/os-release` 时触发，NixOS 不会走到。
  - `gsettingsbackend.cpp` 注释里的 `/usr/lib/x86_64-linux-gnu/...` 仅文档字符串，
    非运行时路径。
- 无 gsettings schema / dbus service / systemd unit。

### dtkgui
- **postPatch**：
  - `src/util/dsvgrenderer.cpp`：`QLibrary("rsvg-2","2")` → librsvg 绝对路径
    （NixOS 无 `/usr/lib` 供 dlopen 查找）。
  - `src/kernel/kernel.cmake`：`/usr/share/dsg/configs/org.deepin.dtk.preference.json`
    → `${dtkcommon}/share/dsg/configs/...`（编译期嵌入，必须指向 dtkcommon）。
- **硬编码路径检查**：
  - `cmake/FindFreeImage.cmake` 里的 `/usr/include`、`/usr/lib` 仅是 find 提示
    路径（`find_path`/`find_library` 的 hints），nixpkgs 环境会先命中，无影响。
  - `tools/dci-icon-theme/main.cpp` 的 `/usr/share/icons/...` 仅 CLI 帮助示例。
  - `tools/dde-kwin-debug/main.cpp` 的 `/usr/lib/deepin-turbo` 仅 strstr 比较。
- `libexec/dtk6/DGui/bin/*` 工具需 `wrapQtApp`（dci-iconfinder、deepin-gui-settings、
  dci-icon-theme 等；其中 single-instance-demo/dnd-test-server 是 example）。
- 无 gsettings/dbus service/systemd unit。

### dtkwidget
- **postPatch**：
  - `src/widgets/dapplication.cpp`：`GenericDataLocation` 追加 `$out/share`。
  - `src/widgets/dprintpreviewdialog.cpp`：打印预览第三方插件查找路径
    `/usr/share/deepin/dtk/plugins/printsupport` → `/run/current-system/sw/share/...`
    （可选扩展，无插件时打印预览仍用默认设置）。
- **cmakeFlags**：`-DBUILD_EXAMPLES=OFF -DBUILD_PLUGINS=OFF`（默认 ON 会构建
  19MB 的 `collections` example 和 designer 插件；example 里还有硬编码
  `/usr/share/icons/bloom/...` 图标路径，仅 demo 用）。
- **硬编码路径检查**：`plugin/dtkuidemo/mainwindow.cpp` 的 bloom 图标路径随
  `BUILD_PLUGINS=OFF` 不再构建；`dapplication.cpp` 里的 `/usr/share/.../translations`
  仅 Doxygen 文档。
- 无 gsettings/dbus service/systemd unit（`mpris` 相关只是 dbus 客户端接口）。

### dtkdeclarative
- `QML_INSTALL_DIR=$out/${qtbase.qtQmlPrefix}`（QML 模块装到标准 qt6/qml 路径）。
- `preConfigure` 额外 `QML2_IMPORT_PATH`。
- 无硬编码 FHS 路径、无 gsettings/dbus service/systemd unit。

### dtksystemsettings
- 依赖 `libxcrypt`（`crypt()`，账号相关）。
- `-DDTK_INCLUDE_INSTALL_DIR=$dev/include/dtk/DSystemSettings`。
- **硬编码路径检查**：
  - `src/accounts/dglobalconfig.h` 的 `/var/lib/AccountsService/...`、
    `/var/lib/dde-daemon/secret-question/` 是 AccountsService 标准路径（宿主一致），
    NixOS 由 `dde-account-faces` + `deepin-daemon` 提供，不改。
  - `src/login/dloginsession.cpp` 的 `/etc/xdg` 是 XDG 标准。
- 无 gsettings/dbus service/systemd unit。

## 已知遗留

- dtkgui 的 `examples/` 无条件构建（上游无 `BUILD_EXAMPLES` 守卫），当前随
  `libexec/dtk6/DGui/bin` 一起安装部分 example/tool。体积可接受，暂不 patch
  CMakeLists 关闭（避免引入不必要的源码 patch）。
- dtksystemsettings 的 `/var/lib/AccountsService` 依赖运行时 AccountsService
  与 `dde-account-faces` 提供的数据；若上层只链接不启用相关服务，读取失败时
  该库有默认兜底。
