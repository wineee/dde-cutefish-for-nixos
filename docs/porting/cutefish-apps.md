# cutefish 应用层打包（L3）

以 `cutefish-text-editor` 为例。这一层的仓库（filemanager / settings /
terminal / text-editor / video-player / calendar / system-monitor /
xdg-desktop-portal-cutefish）结构高度一致，可以照抄。

## 一、共同套路

顶层 `CMakeLists.txt` 的形式都是：

```cmake
find_package(CutefishToolkit REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(<X> REQUIRED IMPORTED_TARGET <pc 名>)
...
cutefish_add_translations(<target 名> SOURCES src DESKTOP_FILES <x>.desktop)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/<x>.desktop
        DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
```

所以包的骨架是：

```nix
nativeBuildInputs = [ cmake pkg-config gettext ];
buildInputs = [ cutefish-toolkit <pkg-config 对应的包> ];
cmakeFlags = [ "-DBUILD_TESTING=OFF" ];
```

## 二、两个容易漏的点

**1. `gettext` 必须进 nativeBuildInputs。**

`CutefishTranslations.cmake` 里的 `cutefish_add_translations()` 是用
`find_program(msgfmt)` 找工具的，**找不到时只打一行 STATUS 就跳过翻译**，
不会报错。上游 Debian 打包自然有 gettext，nix 里忘了加就是静默丢翻译。

这件事回头发现时，已经打好的 `cutefish-toolkit` 正踩在上面：它的 `po/ja.po`
一直被丢掉，产物里没有 `share/locale/ja/LC_MESSAGES/cutefish-toolkit.mo`。
加上 `gettext` 后就正常了。检查方法：

```bash
nix build .#<pkg> --print-out-paths --no-link | xargs -I{} find {} -name '*.mo'
```

**2. `include(CTest)` 会把 `BUILD_TESTING` 默认打开。**

每个仓库顶层都有 `include(CTest)` + `if(BUILD_TESTING) add_subdirectory(tests)`。
测试目标要 `GTest`，而且 `gtest_discover_tests()` 是**在构建期跑一遍可执行文件**
去列举用例 —— UI 测试要开窗口，`text-editor-capture`/`-live` 要 live session。
不加 `-DBUILD_TESTING=OFF` 就得额外提供 gtest 并处理运行期依赖，所以默认关掉。

## 三、cutefish-text-editor

- 仓库 `cutefishos/text-editor`，rev `c17fab33`，BSD-3-Clause。
- 依赖：`cutefish-toolkit` + `icu`（`icu-uc`）+ `pcre2`（`libpcre2-8`，
  正则查找）。与 `packaging/debian/text-editor/debian/control` 的
  Build-Depends 一致。
- 源码里**没有** `/usr` 之类硬编码路径：数据目录走 toolkit 的
  `paths::dataHome()`，配置文件走 `paths::cutefishConfig()`，都已经被
  `toolkit-xdg-paths.patch` 修好了，`~/` 侧的路径本来就不需要改。
- 产物只有 `bin/cutefish-text-editor` 和 `share/applications/*.desktop`。
  目前 `po/` 里只有 `.pot`，没有 `.po`，所以这一版没有任何翻译产物。
- `.desktop` 的 `MimeType` 很长（30 多种），`Categories=Utility;TextEditor;`。
  默认程序关联走标准的 `xdg-mime default`，等应用层打齐、桌面能选默认
  程序时才有意义。

## 四、应用能否在 sway 下跑（VM 验证思路）

toolkit 在 `src/CMakeLists.txt` 里为一堆 wayland 协议生成绑定代码，其中带
`cutefish-` 前缀的三个（`cutefish-shell-v1`、`cutefish-window-hints-v1`、
`cutefish-surface-blur-v1`）是自研的，其余都是标准/ staging 协议
（xdg-shell、viewporter、fractional-scale-v1、cursor-shape-v1、
text-input-unstable-v3 …）。自研协议在运行期绑定、不存在就退化，因此
**text-editor 是可以在 sway 会话里启动的** —— 这也让它成为 toolkit 的
第一个端到端验证手段，比等 compositor 早得多。

`vm-cutefish/flake.nix` 的 systemPackages 里已经加了它（`Mod+d` 里搜
`cutefish-text-editor`），VM 构建通过，`sw/bin` 与 `sw/share/applications`
里都到位。

## 五、其余应用（2026-10-22 全部构建通过）

依赖都来自仓库自己的 `find_package` / `pkg_check_modules`，缺哪一个 CMake 会
直接报错，所以按 CMakeLists 逐一对照填 `buildInputs` 即可：

| 包 | 额外依赖 | 需要改的路径 |
|---|---|---|
| cutefish-calendar | `libical`、`icu`、`curl` | 无（唯一的第二个目标 `cutefish-calendar-reminders` 也在 `bin/`） |
| cutefish-filemanager | `CutefishFiles`（framework）、`fuse3`、`libssh`、`libmtp`、`libarchive`、`libzip`、`samba`、`systemd` | 无 |
| cutefish-settings | framework 的多个组件、`fontconfig`、`expat`、`icu`、`libxkbcommon`、`libxcrypt`、`systemd`、`xorg.libXcursor`、`xkeyboard-config`、`tzdata`、`shadow` | 见下 |
| cutefish-system-monitor | `icu`、`hwdata` | `gpureader.cpp` 的 pci.ids |
| cutefish-terminal | `icu`、`pcre2`（`qmltermwidget` 要 16 位那个）、`libxkbcommon`、`runtimeShell` | 见下 |
| cutefish-video-player | `icu`、`mpv` | 无 |
| xdg-desktop-portal-cutefish | `systemd`、`pipewire`、`wayland*`、`libdrm`、`libgbm` | 无（纯粹非 FHS） |
| cutefish-qt-plugins | `qt6Packages.qtbase`、`qttools`、`librsvg`、`wayland*` | 无；插件包，必须 `dontWrapQtApps = true` |

两处值得记一笔：

- **settings 的每个页面自带一份 `page.cmake`**，各自 `find_package(
  CutefishClients ...)`、`pkg_check_modules(...)`、`find_library(crypt)`，
  于是它的依赖列表比别的应用长一截（字体页要 fontconfig、蓝牙页要 systemd、
  光标主题页要 xcursor、账户页要 crypt 与 passwd）。
- **terminal 的 `qmltermwidget/` 是一个独立子树，有自己的 CMakeLists**，要
  `pcre2`（16 位）和 `xkbcommon`；它的三处 shell 默认值（`/bin/bash`、
  `/bin/sh`）都要换成 `runtimeShell`。

`settings` 改的四处 FHS 路径：`keyboard.cpp` 的 `evdev.xml`、
`passwordchanger.h` 的 `passwd`、`passwordchanger.cpp` 给 `passwd` 用的
`PATH`、`timezonemap.cpp` 的 `zone.tab`；`cursorthemes.cpp` 里最后的
`/usr/share/pixmaps` 直接删掉（`paths::dataDirectories()` 已经 XDG 化，见
`toolkit-xdg-paths.patch`），`.desktop` 的 `Exec=/usr/bin/` 改成裸命令名。

另外所有仓库顶层都有 `include(CTest)`，所以 `BUILD_TESTING` 必关（见第二节）。
