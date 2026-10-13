# AI Agent Guide

> 本文档面向 AI 编码代理（以及未来的维护者），提供在 dde-nixos 仓库里高效、
> 正确地工作所需的上下文。人类维护者也可借此快速了解仓库约定与当前状态。

## 1. 仓库定位与总体目标

- **目标**：把 DDE（Deepin Desktop Environment）在 NixOS 上重新跑起来，并
  逐步把整套组件迁移到 Qt6。未来窗口管理器打包 **treeland**。
- **源码基线**：包定义同步自 nixpkgs 移除 DDE 前的最后完整 commit
  `96e751adaf2f`（`pkgs/desktops/deepin`），NixOS 模块来自 `15a586f29d59`。
- **命名约定**：DTK 库统一「去 6 后缀」——`dtkcore`/`dtkgui`/`dtkwidget`/
  `dtkdeclarative`/`dtksystemsettings`/`dtklog` 都是 Qt6 版本，Qt5 版本已删除。
- **维护策略**：`packages/default.nix` 里只启用「已升级并构建通过」的包，
  其余一律注释。升级一个、验证一个、启用一个。

## 2. 目录布局

```
.
├── flake.nix                 # overlays 注入 pkgs.deepin + nixosModules + 每系统别名
├── packages/
│   ├── default.nix           # 包 scope 入口（唯一维护清单）
│   ├── library/              # DTK + 支撑库（Qt6）
│   ├── core/                 # 核心组件（dde-session、dde-shell、dde-*-manager…）
│   ├── apps/                 # 桌面应用（deepin-terminal 等）
│   ├── artwork/              # 主题/图标/壁纸/头像（纯数据）
│   ├── go-package/           # Go 服务（dde-daemon、startdde…）
│   └── tools/                # 构建/工具（deepin-gettext-tools 等）
├── nixos-modules/deepin/     # NixOS 模块
├── docs/                     # development.md（维护状态）+ 本文件
├── dde/                      # 参考代码（已被 .gitignore 忽略，不会提交）
│   └── nixos-unstable-dde-25-flake/   # 上游 Qt6 迁移参考实现
├── vm/  vm2/                 # 虚拟机测试 flake
└── readme.md
```

## 3. 当前进度（截至最近提交）

- ✅ 已升级并维护：`dtkcommon`/`dtklog`/`dtkcore`/`dtkgui`/`dtkwidget`/
  `dtkdeclarative`/`dtksystemsettings`（统一 6.7.50 / 6.6.22，Qt6）、
  `qt6integration`/`qt6platform-plugins`（6.0.50）、`treeland-protocols`（0.7.0）。
- ✅ 应用：`deepin-terminal`（6.5.40，第一个 Qt6 应用）。
- ✅ 支撑库：`deepin-pdfium`、`docparser`、`gio-qt`、`udisks2-qt6`、`qt6mpris`、
  `util-dfm`。
- ✅ Go 服务：`dde-api`（6.0.48）、`dde-daemon`（6.1.107）、`startdde`（6.1.6）、
  `deepin-pw-check`（6.0.12）、`deepin-desktop-schemas`（6.0.13）。
- ✅ 核心组件（Qt6）：`dde-application-manager`（1.2.45）、
  `deepin-service-manager`（1.0.21）、`dde-tray-loader`（2.0.27）、
  `dde-shell`（2.0.52）、`dde-file-manager`（6.5.121）、
  `dde-session-ui`（6.0.50）、`dde-launchpad`（2.0.48）、
  `dde-appearance`（1.1.86）、`dde-clipboard`（6.1.35）、
  `dde-grand-search`（6.1.1）、`dde-app-services`（1.0.46）、
  `dde-session`（2.0.33）、`dde-session-shell`（6.0.68）、
  `dde-control-center`（6.1.109）、`dde-network-core`（2.0.102）。
- ✅ artwork 全家桶：account-faces / icon / wallpapers / gtk-theme /
  sound-theme / desktop-theme。
- ✅ `deepin-desktop-base`（2026.09.04，已移到 core/ 并 NixOS 品牌化）。
- ❌ 已删除：`qt5platform-plugins`、`qt5integration`、`deepin-wayland-protocols`、
  `dwayland`、`deepin-kwin`、`udisks2-qt5`、`dde-api-proxy`、
  `dde-qt-dbus-factory`、`disomaster`、`dpa-ext-gnomekeyring`、`dde-widgets`
  （均加 alias throw）。
- ✅ NixOS 模块清理：移除已删包的引用，默认 session 改为 `deepin`，
  `deepin-anything` 模块已注释（暂不启用）。
- ⏳ 阻塞项：无（所有已记录 blocker 均已解决）。
- 🖥️ VM 调试：DDM + Treeland 启动链路已打通（0 failed units），登录画面
  待最后一项 output enable 问题解决。见第 9 节。

详见 `docs/development.md` 的「Maintained packages」表。

## 4. 参考实现（dde/ 子目录）

`dde/nixos-unstable-dde-25-flake/` 是外部 Qt6 迁移参考项目（ktechmidas 的
DDE 25 flake），已放入仓库但**被 .gitignore 忽略**。它采用与我们不同的命名
（`dtk6core`/`dtk6widget` 等带 6 后缀），版本也略有差异（6.0.50 系列），但
在包定义、patch、依赖选择上是极好的参考。

**如何利用**：
```bash
# 查看某个包的上游 Qt6 定义
cat dde/nixos-unstable-dde-25-flake/packages/library/<pkg>/default.nix
# 查它的 hash / patch / 依赖选择，再适配到我们的命名与版本
```

**注意差异**（避免直接照抄踩坑）：
- 命名：参考用 `dtk6*`，我们用无 6 后缀。
- DTK 版本：参考 6.0.50，我们 6.7.50（`-DDTK5=OFF` 单源码双构建）。
- 参考的 `PROGRESS.md`/`RESEARCH.md` 记录了 Qt6 迁移的决策与踩坑，值得一读。

## 5. 标准工作流（给 AI 代理的 SOP）

### 升级一个包
1. 查上游最新 tag：`gh api repos/linuxdeepin/<repo>/tags --jq '.[].name'`。
2. 取 SRI hash：
   ```bash
   nix-prefetch-url --unpack https://github.com/<owner>/<repo>/archive/refs/tags/<ver>.tar.gz
   # 得到 base32，再：
   nix hash to-sri --type sha256 <base32>
   ```
   ⚠️ 不要用 `refs/tags` 的 tarball hash 直接填 `fetchFromGitHub`（它抓的是
   `archive/<rev>.tar.gz`，hash 不同）。见 development.md「SRI hash」。
3. 先看 `dde/nixos-unstable-dde-25-flake/` 是否已有对应定义，参考其 patch 和
   buildInputs；再适配命名/版本。
4. 写/改 `packages/<分类>/<pkg>/default.nix`，在 `packages/default.nix` 取消注释。
5. `nix build .#<pkg> --no-link` 验证。失败时按 development.md 的 gotchas 排查。
6. 更新 `docs/development.md` 的维护表 + 升级日志，然后按中文 commit 规范提交。

### 删除一个废弃包
1. `git rm -r packages/<分类>/<pkg>`。
2. 清掉 `packages/default.nix` 里的引用（含注释）。
3. **必须**检查 `nixos-modules/deepin/*.nix` 是否引用，一并清理。
4. 全文 `grep -rn "<pkg>" packages/ nixos-modules/` 确认无残留。

## 6. 常见坑（速查）

- **dtkgui 缺 dsg JSON**：`src/kernel/kernel.cmake` 硬编码
  `/usr/share/dsg/configs/org.deepin.dtk.preference.json`，需 postPatch 替换为
  `${dtkcommon}/share/dsg/...`。
- **CMake 4.x `-pie`**：deepin 项目常写 `add_link_options(... -pie ...)`，会让
  shared lib 链接报 `undefined reference to main`，需 patch 掉 `-pie`。
- **`.pc` double-prefix**：cmake 生成的 pkg-config 常写
  `libdir=${prefix}/@CMAKE_INSTALL_LIBDIR@`，nix 下产生 `${prefix}//nix/store/...`，
  需 postInstall `sed` 掉 `${prefix}/`。
- **纯数据包 + papirus 传播 qtbase**：`dontWrapQtApps = true` 否则
  qtPreHook 报「no wrapping behavior specified」。
- **icon-theme 的 `gtk-update-icon-cache`**：对无 `index.theme` 的目录返回非零，
  需 `if [ -f $theme/index.theme ]` 守卫。
- **空 `--replace` 目标**：indented Nix string 里 `''` 是终止符，不能作空 replace，
  换成注释占位。
- **`finalAttrs` 下不能裸用 `src`**：phase 里引用源码要用 `finalAttrs.src.name`。

完整版见 `docs/development.md`「Gotchas」。

## 7. 提交规范

遵循中文团队 commit 惯例（Conventional Commits 中文适配）：
`<type>(<scope>): <中文简述>` + 可选 EN/ZH body。示例：

```
deepin-terminal: upgrade to 6.5.40 (Qt6)

First application migrated to the Qt6/Dtk6 stack.
- 6.0.17 -> 6.5.40
- drop Qt5 deps (qt5integration, qt5platform-plugins, chrpath)
```

type 常用：`feat`/`fix`/`refactor`/`remove`/`chore`；scope 用包名或目录。

## 8. 待办 / 下一步

1. `packages/apps/` 仍有一批应用待升级（由另一 AI 并行负责，提交时注意不碰其文件）。
2. 未来窗管：treeland（当前已删 deepin-kwin/dwayland/deepin-wayland-protocols）。
3. `deepin-anything`：模块已注释，待内核模块 + 用户态工具准备好后再启用。

## 9. VM 调试状态与已知限制（treeland 登录链路）

> 调试入口：`vm/flake.nix`（`nixosConfigurations.vm`），启用
> `services.desktopManager.deepin` + `services.displayManager.ddm`，QEMU 用
> `virtio-vga-gl` + `gtk,gl=on`，SSH 转发 `host:2222 → guest:22`。

### 已打通

- **全链路 active、0 failed units**：`dde-seatd`、`ddm`、`treeland`、
  `display-manager`、`dde-system-daemon`（注册 D-Bus `Accounts1`/`Display1`/
  `Daemon1` 等）均正常。
- **treeland 启动链**：libseat(seatd) → DRM(virtio_gpu) → Xwayland `:0`
  running → LockScreen 插件加载。
- **账户修复**：`dde-daemon.nix` 创建 `deepin-daemon`（附组 `netdev`）与
  `deepin-admin-daemon`；`app-services.nix` 删除了错误的 `dde-dconfig-daemon`
  用户（上游 sysusers 只建 `deepin-daemon`）。修复前 `dde-dconfig-daemon`
  因 `Unknown user 'deepin-daemon'` 以 217/USER 失败。
- **PATH 修复**：`deepin.nix` 加 `systemd.services.treeland.path =
  [ pkgs.xwayland ]`。treeland.service 是上游 `linked` unit（无 NixOS
  drop-in），不注入默认 PATH，导致 `treeland.sh` 的 `realpath`/`grep` exit
  127、`treeland-xwayland` 的 `execvp("Xwayland")` 找不到二进制。

### 已知限制（待解决）

1. **output 未 enable**：treeland 日志 `Temporarily disabled output during
   initial scan "Virtual-1"` 后无 `Enabled output`。DConfig
   `org.desktopspec.ConfigManager` 已注册、`org.deepin.dde.treeland.output`
   资源可读（width/height/x 均为默认 0，即无已保存模式），但
   `restoreInitialOutputConfiguration` 未把 output 重新 enable，QEMU 里
   仍显示 `Display output is not active`。定位到源码
   `src/seat/helper.cpp` 的 `restoreExtensionModeFromConfig()` 应无条件
   `outputObject->enable()`，尚未确认为何未触发。
2. **登录界面缺默认头像**：`QtIcon: Cannot open:
   file:///var/lib/AccountsService/icons/default`。宿主 deepin 有该 symlink
   （指向 `icons/animal/raccoon.png`），VM 缺失。
3. **treeland unit 与宿主差异**：VM 由 NixOS 生成，`NoNewPrivileges=true`
   （宿主为 `false`，注释说明 NVIDIA setuid 需要）；宿主另有
   `StandardOutput=null`、`AmbientCapabilities=CAP_IPC_OWNER` 等。若后续
   NVIDIA/真实硬件异常，优先对齐这些项。
4. **DSG_DATA_DIRS 噪声日志**：`dde-dconfig-daemon` 报大量
   `Can't load meta file from local prefix: ""`（tray-loader/dock/network
   等 app 的 meta 未安装），不影响 treeland 自身 DConfig，可后续清理。
