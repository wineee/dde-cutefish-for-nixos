# dde-appearance 移植文档

> 上游 `linuxdeepin/dde-appearance` 1.1.86。**不是独立 daemon**：编译成
> deepin-service-manager 插件（`lib/deepin-service-manager/libplugin-dde-appearance.so`），
> 由 `deepin-service-manager.service` 加载，对外暴露 `org.deepin.dde.Appearance1`。

## 依赖链

```
dtkcore / dtkgui
qtbase（+ wrapQtAppsHook）、qt6Packages.qttools
kdePackages.{kwindowsystem,kconfig,kglobalaccel}
lomiri-qt6.gsettings-qt          # themes.cpp 用 QGSettings
deepin-service-manager           # 插件宿主 + 插件配置目录
glib gtk3 fontconfig openssl systemd
libxcursor libxfixes libx11 libxcb xcbutilcursor

← dde-session / ddm / dde-control-center（运行时经 Appearance1 调用）
```

## patches

### `no-fakewm.patch`：不编译 X11 的 dde-fakewm

上游顶层 `add_subdirectory(fakewm)` 无条件构建 `dde-fakewm` —— 一个伪造 X11 WM、
占用 `com.deepin.wm` 的辅助进程，另装 `com.deepin.wm.service`（dbus）与
`dde-fakewm.service`（systemd user）。本移植只支持 wayland（treeland），而且
**上游自己的 unit 就带** `ExecCondition=test "$XDG_SESSION_TYPE" != "wayland" || exit 2`
—— wayland 下本来就不会启动它。patch 去掉三处：

| 文件 | 改动 |
|---|---|
| `CMakeLists.txt` | `add_subdirectory(fakewm)` 改为注释 |
| `misc/CMakeLists.txt` | `add_subdirectory(systemd)` 改为注释（该目录只装 dde-fakewm.service） |
| `misc/dbusservice/CMakeLists.txt` | 删掉 `com.deepin.wm.service` 的 `configure_file` 与安装项 |

`src/service/dbus/appearancedbusproxy.cpp` 里对 `com.deepin.wm` 的 `DDBusInterface`
**保留**：它是懒加载客户端，wayland 下不可达时的失败与上游一致（上游 wayland 下
同样没有 WM 在跑）。`dde-api` 的 `themes/settings.go` 同理，只在调用时才连。

## 硬编码路径（postPatch）

| 文件 | 上游 | 改为 |
|---|---|---|
| `src/service/modules/common/commondefine.h` | `/usr/share/zoneinfo/zone1970.tab` | `${tzdata}/…` |
| `src/service/modules/api/locale.cpp` | `/usr/share/locale/locale.alias` | `${glibc}/…` |
| `src/service/modules/api/themes.cpp` | `#include <QGSettings/QGSettings>` | `#include <QGSettings>` |
| `src/service/modules/api/compatibleengine.cpp` | `/usr/share/dsg/icons/` | `$out/share/dsg/icons/` |
| `src/service/modules/subthemes/customtheme.cpp` | `/usr/share/dde-appearance/` | `$out/share/dde-appearance/` |
| `src/service/impl/appearancemanager.cpp`、`modules/background/backgrounds.cpp` | `/usr/share/wallpapers/deepin` | `/run/current-system/sw/share/wallpapers/deepin` |
| `src/service/dbus/appearance1thread.cpp`、`toolGenerate/dconfig2cpp/org_deepin_dde_appearance.hpp`、`misc/dconfig/org.deepin.dde.appearance.json` | `/usr/share/backgrounds/default_background.jpg` | `/run/current-system/sw/share/backgrounds/…` |

`themes.cpp` 那处是因为 nixpkgs 的 `lomiri-qt6.gsettings-qt` 的 `.pc` 只提供
`-I…/include/qt6/QGSettings`，不支持 deepin 的 `<QGSettings/QGSettings>` 写法。

**`glibc` 只能作函数参数，不能进 `buildInputs`**：进 buildInputs 会把 glibc 的
include 目录塞进搜索路径，导致 `stdlib.h` 之类解析错乱（fakewm 编译失败正是
由此暴露的；现在 fakewm 已不编译，但这条约束仍然成立）。

## 编译输出（对 NixOS 模块的影响）

| 类型 | 路径 |
|---|---|
| 服务插件 | `lib/deepin-service-manager/libplugin-dde-appearance.so` |
| 插件配置 | `share/deepin-service-manager/user/plugin-dde-appearance.json` |
| dconfig | `share/dsg/configs/org.deepin.dde.appearance/` |
| dbus session service | `share/dbus-1/services/org.deepin.dde.Appearance1.service` |
| 翻译 | `share/plugin-dde-appearance/translations/` |
| 资源 | `share/dde-appearance/custom.png` |
| 用户/组、polkit、systemd unit | 无 |

`pathsToLink` 需要 `/share/dsg`、`/share/deepin-service-manager`、
`/share/plugin-dde-appearance`（翻译经 `QStandardPaths::GenericDataLocation` 找到，
即 `XDG_DATA_DIRS` → `/run/current-system/sw/share`）。

## 已知遗留

- X11 会话下 `com.deepin.wm` 无人提供；本移植不支持 X11，无影响。
- dbus service 的 `Exec=/bin/false` 是委托 systemd 的占位符（存在
  `SystemdService=` 时 bus 忽略 `Exec`），NixOS 上无害。
