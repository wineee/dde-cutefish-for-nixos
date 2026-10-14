# dde-session-shell 移植文档

> 版本：6.0.68 ｜ 仓库：linuxdeepin/dde-session-shell-**snipe** ｜ 许可：GPL-3+

仓库名不是 `dde-session-shell` 而是 `dde-session-shell-snipe`（代码独立成库）。
6.0.x 起锁屏迁到该库，旧库停留在 5.x。

## 依赖链

```
dtkcore / dtkwidget / dtkcommon
qtbase / qtsvg / qtdeclarative
linux-pam → openssl
libx11/xcb/xi/xcursor/xfixes/xrandr/xext/xtst
systemd（systemd-detect-virt）、glib（dbus-send）
setxkbmap、xdotool（键盘 grab 用）
```

产出：`dde-lock`（真身在 `libexec/deepin/`，`bin/dde-lock` 是
`deepin-security-loader` 包装脚本）、`lib/security/pam_inhibit_autologin.so`、
`deepin-greeter` 脚本、dbus service、dde-lock.desktop、log/debug config。

## greeter 被整体禁用

上游 greeter 依赖 `liblightdm-qt6-3`，nixpkgs 无此 Qt6 绑定。在 CMakeLists 里：

- 注释 `pkg_check_modules(Greeter REQUIRED …)`
- 从 `dde-lock` 链接行移除 `${Greeter_LIBRARIES}`
- 用 `sed` 在 `set(GREETER_SRCS` 前插 `if(FALSE)`、在 `add_subdirectory(tests)` 前插
  `endif()`，跳过整段 greeter 块（GREETER_SRCS / add_executable / target_* / install）

### 安装分支（`DDE_SESSION_SHELL_SNIPE=ON` → `DISABLE_DSS_SNIPE=FALSE`）

| 分支 | 文件 | 是否进产物 |
|---|---|---|
| `else() # snipe` | `files/snipe/deepin-greeter` → `bin/` | ✅ |
| `else() # snipe` | `files/snipe/scripts/*` → `etc/deepin/greeters.d/` | ✅ |
| `else() # snipe` | `files/snipe/dde-lock.desktop`、`files/snipe/*.service` | ✅ |
| `if(DISABLE_DSS_SNIPE)`（Qt5/v20） | `files/deepin-greeter`、`files/x/*`、`files/wayland/*`、`files/launch-binary` | ❌ |
| `if(DISABLE_DSS_SNIPE)` | `plugins/*`（含 `login-gesture`） | ❌ |
| 两个分支之外（无条件） | `files/dde-lock-loader-wrapper`、`files/pre-greeter`、`files/50-deepin.conf`、`files/x/lightdm-deepin-greeter.desktop`、`files/lightdm-deepin-greeter.conf`、`src/pam-inhibit-autologin` | ✅ |

注意 `plugins/CMakeLists.txt` 整个包在 `if(DISABLE_DSS_SNIPE)` 里 →
`plugins/login-gesture/CMakeLists.txt` 的 `-DQM_FILES_DIR="/usr/share/…"` 是死代码，
不必处理。

## 硬编码路径检查

原先用 `find … -exec sed` 对 `*.cpp/*.h/.service/.desktop/CMakeLists.txt` 批量替换，
问题有二：**漏文件**（`.c`、`.json`、无后缀脚本都没覆盖），以及 `/usr/lib` 的
blanket 会改到不该动的地方。现改为逐文件 `substituteInPlace --replace-fail`，按目标
分组——同一 pattern 必须在组内**每个**文件都命中，否则构建失败，正好用来防漏。

### 编译进二进制的源码路径

| 文件 | 原值 | 改为 |
|---|---|---|
| `src/global_util/constants.h` ×4 | `/usr/share/icons/default/index.theme`、`/usr/share/dde-session-shell/dde-session-shell.conf`、`/usr/share/dde-session-ui/{dde-session-ui.conf,dde-shutdown.conf}` | `/run/current-system/sw/share/…` |
| `src/global_util/public_func.cpp` ×2 | `/usr/share/icons/bloom/cursors/loginspinner[ @2x]`、`/usr/share/dde-session-shell/translations/dde-session-shell_` | `/run/current-system/sw/share/…` |
| `src/global_util/xkbparser.h` | `/usr/share/X11/xkb/rules/base.xml` | `/run/current-system/sw/share/…` |
| `lighter-greeter/lighterbackground.cpp`、`src/session-widgets/userinfo.cpp`、`src/widgets/fullscreenbackground.cpp` | `/usr/share/backgrounds/default_background.jpg` | `/run/current-system/sw/share/…` |
| `src/session-widgets/lockcontent.cpp` | `/usr/share/backgrounds/deepin/desktop.jpg` | `/run/current-system/sw/share/…` |
| `src/global_util/plugin_manager/modules_loader.cpp` | `/usr/lib/dde-session-shell/modules` | `/run/current-system/sw/lib/…` |
| `src/session-widgets/auth_module.h` ×2 | `/usr/lib/{dde-control-center/reset-password-dialog,deepin-deepinid-daemon/deepin-deepinid-daemon}` | `/run/current-system/sw/lib/…` |
| `src/pam-inhibit-autologin/pam_inhibit_autologin.c` | `/usr/share/dde-session-shell/greeters.d/pre-greeter` | `/run/current-system/sw/share/…` |

指向 `…/sw` 而非 `$out`：这些数据（图标、翻译、背景、插件模块、reset 对话框）
分别由其他包提供，靠 `environment.pathsToLink` 汇聚到系统 profile。
`modules_loader.cpp` 只有一条 pattern `/usr/lib/dde-session-shell/modules`——因为
`substitute` 按顺序应用，写成两条的话第二条会被第一条吃掉，`--replace-fail` 直接报错。

### 外部程序路径

| 文件 | 原值 | 改为 |
|---|---|---|
| `…/keyboardplantform_wayland.cpp`、`…/auth_password.cpp` | `/usr/bin/setxkbmap` | `${setxkbmap}/bin/setxkbmap` |
| `…/keyboardplantform_wayland.cpp` | `/usr/bin/xdotool` | `${xdotool}/bin/xdotool` |
| `…/authinterface.cpp` | `/usr/bin/systemd-detect-virt` | `${systemd}/bin/systemd-detect-virt` |

### 安装脚本 / 单元文件

| 文件 | 原值 | 改为 |
|---|---|---|
| `files/dde-lock-loader-wrapper` | `REAL_BINARY="/usr/libexec/deepin/dde-lock"` | `"$out/libexec/deepin/dde-lock"` |
| `files/pre-greeter` | `/usr/share/dde-session-shell/greeters.d/launch.conf.d` | `/run/current-system/sw/share/…` |
| `files/{,snipe/}dde-lock.desktop`、`files/snipe/org.deepin.dde.LockFront1.service`、`files/deepin-log-config/…json` | `/usr/bin/dde-lock` | `$out/bin/dde-lock` |
| `files/com.deepin.dde.{lockFront,shutdownFront}.service`、`files/snipe/org.deepin.dde.ShutdownFront1.service` | `/usr/bin/dbus-send`、`/usr/share/applications/dde-lock.desktop` | `${glib.bin}/bin/dbus-send`、`$out/share/applications/…` |

`bin/dde-lock` 是脚本、真身在 `libexec/deepin/dde-lock`——原 blanket 只 sed
`/usr/bin`，把 `REAL_BINARY` 落下了，锁屏会 exec 一个不存在的路径。这是本次最关键的
一处修复（产物里已确认指向 store 绝对路径）。

CMakeLists 另把 `dde-session-shell.conf` 的安装位置从 `/var/lib/dde-session-shell/`
改到 `${CMAKE_INSTALL_DATADIR}/dde-session-shell/`（运行时已走 DConfig）。

## 编译输出（对 NixOS 模块的影响）

| 输出类型 | 位置 | 说明 |
|---|---|---|
| D-Bus service | `share/dbus-1/services/` | LockFront / ShutdownFront |
| pam 模块 | `lib/security/pam_inhibit_autologin.so` | 自动登录前调 `pre-greeter`；NixOS 未挂载，属可选 |
| dconfig / log / debug config | `share/dsg/configs/`、`share/deepin-log-viewer/`、`share/deepin-debug-config/` | 见下 |
| desktop | `share/applications/dde-lock.desktop` | — |
| systemd unit / gschema / polkit / 用户组 | **无** | — |

`pathsToLink` 需覆盖 `/share/dde-session-shell`、`/share/dde-session-ui`（translations、
conf 运行时读），均已在 `deepin.nix`。日志/调试配置装在
`share/deepin-log-viewer`、`share/deepin-debug-config`——这两个读者
（deepin-log-viewer / deepin-debug-config）**不在本仓库**，故未加进 `pathsToLink`。

## 已知遗留

产物中残留的 `/usr` 全部来自 lightdm/greeter 专用文件（本项目用 DDM + treeland
登录，不用 lightdm）：

- `share/xgreeters/lightdm-deepin-greeter.desktop` → `/usr/bin/deepin-greeter`
- `etc/deepin/greeters.d/lightdm-deepin-greeter` → `/usr/bin/greeter-display-setting`、
  `/usr/bin/lightdm-deepin-greeter`、`/usr/lib/deepin-daemon/greeter-display-daemon`、
  `/usr/share/dde-session-shell/greeters.d/pre-greeter`
- `share/lightdm/lightdm.conf.d/50-deepin.conf` → `/usr/sbin/deepin-fix-xauthority-perm`
- `share/deepin-authentication/privileges/lightdm-deepin-greeter.conf` →
  `/usr/sbin/lightdm`、`/usr/bin/lightdm-deepin-greeter`

这些路径对应的程序（`lightdm`、`deepin-greeter`、`greeter-display-setting` 等）在
nixpkgs 里不存在或未构建，修了也无意义，保持原样。

`bin/dde-lock` 里的 `/usr/bin/deepin-security-loader{,-exec}` 刻意保留：在
`[ -x ]` 守卫里，NixOS 上不存在即走直接启动 fallback（已确认 fallback 指向正确）。
