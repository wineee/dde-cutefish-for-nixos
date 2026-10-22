# cutefish-core / cutefish-dm 移植记录

上游：`github.com/cutefishos/cutefish-core`、`github.com/cutefishos/cutefish-dm`
许可：BSD-3-Clause。上游不发布 tag，全部按 commit 钉。

`cutefish-core` 不是单个程序，而是一组会话与后台服务；`cutefish-dm` 是自己的
显示管理器（登录界面就是 compositor 本身，`--login`）。两者都在 toolkit +
framework + compositor 之上，是 L2 层的全部内容。

## 一、core 装了什么

| 可执行文件 | 安装位置 | 作用 |
|---|---|---|
| `cutefish-session` | `bin/` | 会话监督者：起 compositor、language/proxy 环境、restart policy |
| `cutefish-wayland-session` | `bin/` | 会话入口脚本（`wayland-sessions` 的 Exec） |
| `cutefish-appruntime` | `bin/` | 按应用 scope 起一组进程（含 chromium 开关识别） |
| `cutefish-services` | `bin/` | 外观/壁纸/电量/亮度/崩溃报告/夜灯/权限/代理/定时一条总线上的一个进程 |
| `cutefish-polkit-agent` | `bin/` | polkit 认证代理（走 `polkit-agent-helper-1`） |
| `cutefish-screenrecorder` | `libexec/` | 通过 compositor 的 Wayland 连接录屏（DMA-BUF + VA-API） |
| `cutefish-privacy` | `libexec/` | 摄像头/麦克风开关，**system** D-Bus + systemd unit |
| `cutefish-locales` | `libexec/` | 生成本地化数据，**system** D-Bus + systemd unit（Debian 专用） |

随包装出来的集成面：

- `share/wayland-sessions/cutefish-wayland.desktop`
- `share/dbus-1/system-services/` + `share/dbus-1/system.d/`（Privacy、Locales）
- `share/polkit-1/actions/`（Privacy、Locales）
- `lib/systemd/system/`（`cutefish-locales.service`、`cutefish-privacy.service`）
- `lib/systemd/user/xdg-document-portal.service.d/cutefish-session.conf`（把
  旧 portal 的 `TimeoutStopSec` 压到 2s）
- `lib/udev/rules.d/60-cutefish-privacy.rules`、`60-cutefish-ddc.rules`、
  `lib/modules-load.d/cutefish-ddc.conf`

## 二、必须改的 FHS 路径

逐条改、不批量 sed（见 `AGENTS.md` 四步法）：

| 位置 | 原文 | 改成 |
|---|---|---|
| `session/cutefish-wayland-session` | `exec /usr/bin/cutefish-session` | `$out/bin/cutefish-session` |
| `session/cutefish-wayland.desktop` | `Exec=/usr/bin/...`、`TryExec=/usr/bin/cutefish-compositor` | 裸命令名 / compositor 的 store 路径 |
| `session/processmanager.cpp` | `/usr/bin/cutefish-compositor` | compositor 的 store 路径 |
| `session/CMakeLists.txt` | `DESTINATION /usr/lib/systemd/user` | `lib/systemd/user` |
| `session/application.cpp` | `XDG_DATA_DIRS=/usr/local/share/:/usr/share/` | `/run/current-system/sw/share` |
| `polkit-agent/authsession.cpp` | `/usr/lib/polkit-1/polkit-agent-helper-1` | `${polkit}` 下的同名文件 |
| `cutefish-services/.../wallpapermanager.cpp` | `/usr/share/backgrounds/cutefishos/default.jpg` | `/run/current-system/sw/share/...` |
| `cutefish-services/schedule/scheduleutils.cpp` | `/usr/share/zoneinfo/zone{1970,}.tab` | `${tzdata}` |

两处**有意不改**：

- `locales/localesservice.h` 的 `SUPPORTED`、`/etc/locale.gen`、`localedef`、
  `/usr/lib/locale`：这是 Debian 的 locale-gen 布局（每个 locale 一个目录），
  NixOS 是 `i18n.supportedLocales` 在 glibc 里编一个 `locale-archive`，
  这套管道在 NixOS 上没有对应物。**不启用这个 D-Bus 服务**，留着不报错（文件
  不存在时只是 `access()` 返回 false）。
- `locales/cutefish-locales.service` 的 `ReadWritePaths=-/usr/lib/locale /etc`：
  `-` 前缀表示"不存在则忽略"，且该 unit 不会被启用，无需处理。

`chromiumswitches.cpp` 判 `/usr/lib` 找发行版 wrapper 脚本的分支在 NixOS 上
恒假 —— 结果是直接用 `PATH` 上的可执行文件名，正是想要的。

## 二之二、compositor 的会话伴侣（一处循环依赖）

合成器自己也要改几处 FHS：

| 位置 | 处理 |
|---|---|
| `src/core/compositor_shell.cpp` 的 `/usr/bin/cutefish-services`、`/usr/bin/cutefish-polkit-agent` | 运行期在 `PATH` 里查再 `canonical()`（`compositor-nix-paths.patch`）：core 反过来依赖 compositor，把它的 store 路径编译进来会成环 |
| `src/xwayland/xwayland_server.h` 的 `/usr/bin/Xwayland` | `${xwayland}/bin/Xwayland` |
| `src/auth/login_sessions.cpp` 的两个 wayland-sessions 目录 | `/run/current-system/sw/share/wayland-sessions` |
| `src/shell/wallpaper/wallpaper.cpp`、`src/session/secure_container.cpp` 的默认壁纸 | `/run/current-system/sw/share/backgrounds/cutefishos/default.jpg`（壁纸包是 unfree，合成器不该依赖它） |
| `src/cursor/theme.cpp` 的 `/usr/share/pixmaps` | 删掉（`dataDirectories()` 已 XDG 化） |

安全代理 `runsOneOf()` 是拿 `/proc/<pid>/exe` 的 `canonical()` 结果跟给定列表
比，所以从 `PATH` 查到的 profile 路径还得再 `canonical()` 一次才匹配得上 ——
这是这个补丁里唯一不能简化的地方。

## 三、dm 装了什么、改了什么

- `bin/cutefish-dm`（主守护进程）、`libexec/cutefish-dm-helper`（PAM 会话，
  无事件循环无线程）、`libexec/cutefish-dm-session`（走 login shell 的 wrapper）。
  `DM_HELPER_PATH` / `DM_SESSION_WRAPPER` 由 CMake 从 `LIBEXECDIR` 拼出，
  store 路径天然正确，不用改。
- 改动：`DESTINATION /usr/lib/systemd/{system,user}` → `lib/systemd/...`；
  unit 里 `ExecStart=/usr/bin/cutefish-dm` → store 路径；greeter 命令
  `/usr/bin/cutefish-compositor` → compositor 的 store 路径；会话目录
  `/usr/local/share/wayland-sessions`、`/usr/share/wayland-sessions` →
  `/run/current-system/sw/share/wayland-sessions`。
- `data/*.pam` 装到 `$out/etc/pam.d`：Debian 的 `@include common-*` 在 NixOS 上
  不存在，模块必须自己写 PAM（见下）。

## 四、NixOS 模块侧现状

`services.desktopManager.cutefish.enable` 目前已接上：

- `services.displayManager.sessionPackages = [ cutefish-core ]`（wayland-sessions）
- `services.dbus.packages = [ cutefish-core ]`（system-services + policy）
- `services.udev.packages = [ cutefish-core ]`（privacy / DDC 规则）
- `systemd.packages = [ cutefish-core ]`（unit 与 document-portal drop-in）
- `xdg.portal.extraPortals = [ xdg-desktop-portal-cutefish ]`
- `security.polkit.enable = true` + artwork（图标主题/壁纸）

`systemd.packages` 只**链接** unit，不会自动 enable，所以 locales/privacy 不会
随会话起来；两者分别由 D-Bus system bus 激活和 udev tag 触发。

**还没做的**（`cutefish-dm` 未接入会话选项）：

1. greeter 用户：unit 的 `ConditionUser=!cutefish-greeter` 说明上游预期一个
   独立用户，NixOS 需要 `users.users.cutefish-greeter` + `Group`。
2. PAM：`security.pam.services.cutefish-dm{,-greeter}.text`（参考 Debian 版
   语义自己写，别用上游的 `@include`）。
3. 抢占 `display-manager.service`：dm 的 unit 带 `Alias=display-manager.service`，
   得先把 DM 那套 `services.xserver.displayManager.*` 关掉。
