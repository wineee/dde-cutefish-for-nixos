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
├── dde/                      # 上游源码（.gitignore 忽略，不会提交）
│   ├── src/<repo>            # 需要看代码时才 clone（blobless，带完整历史）
│   └── src-dl/               # fetch.py 下载的 tag 源码 + 工具脚本
├── vm/  vm2/                 # 虚拟机测试 flake
└── readme.md
```

## 3. 当前进度（截至最近提交）

> 版本号以各包 `default.nix` 的 `version` 为准（2026-10-15 核对）。

- ✅ DTK（全 Qt6，统一 6.7.50；`dtksystemsettings` 6.6.22）：
  `dtkcommon`/`dtklog`/`dtkcore`/`dtkgui`/`dtkwidget`/`dtkdeclarative`/
  `dtksystemsettings`；`qt6integration`/`qt6platform-plugins`（6.0.50）、
  `treeland-protocols`（0.7.0）。
- ✅ 应用（**全部 Qt6，11 个**）：`deepin-terminal`（6.5.40）、
  `deepin-calculator`（6.5.40）、`deepin-compressor`（6.5.36）、
  `deepin-draw`（6.5.43）、`deepin-editor`（6.7.0）、`deepin-music`（7.0.70）、
  `deepin-picker`（6.0.12）、`deepin-reader`（6.6.2）、
  `deepin-screensaver`（6.5.11）、`deepin-shortcut-viewer`（5.5.6）、
  `deepin-system-monitor`（6.5.47）。
  除 `deepin-terminal` 外全部在 `deepin.nix` 的 `optionalPackages` 里
  （可用 `environment.deepin.excludePackages` 排除）。
- ✅ 支撑库：`deepin-pdfium`、`docparser`、`gio-qt`、`udisks2-qt6`、`qt6mpris`、
  `util-dfm`。
- ✅ Go 服务：`dde-api`（6.0.48）、`dde-daemon`（6.1.108）、`startdde`（6.1.6）、
  `deepin-pw-check`（6.0.12）、`deepin-desktop-schemas`（6.0.13）。
- ✅ 工具：`deepin-anything`（7.1.0，Qt6）+ `deepin-anything-module`
  （vfs_monitor.ko，按运行内核构建）。
- ✅ 核心组件（Qt6）：`dde-application-manager`（1.2.62）、
  `deepin-service-manager`（1.0.24）、`dde-tray-loader`（2.0.42）、
  `dde-shell`（2.0.57）、`dde-file-manager`（6.6.6）、
  `dde-session-ui`（6.0.50）、`dde-launchpad`（2.0.49）、
  `dde-appearance`（1.1.86）、`dde-clipboard`（6.1.36）、
  `dde-grand-search`（6.1.1）、`dde-app-services`（1.0.46）、
  `dde-session`（2.0.34）、`dde-session-shell`（6.0.68）、
  `dde-control-center`（6.1.110）、`dde-network-core`（2.0.103）、
  `treeland`（0.11.0）、`ddm`（0.4.0）、`dde-seatd`。
- ✅ artwork 全家桶：account-faces / icon / wallpapers / gtk-theme /
  sound-theme / desktop-theme。
- ✅ `deepin-desktop-base`（2026.09.04，已移到 core/ 并 NixOS 品牌化）。
- ❌ 已删除：`qt5platform-plugins`、`qt5integration`、`deepin-wayland-protocols`、
  `dwayland`、`deepin-kwin`、`udisks2-qt5`、`dde-api-proxy`、
  `dde-qt-dbus-factory`、`disomaster`、`dpa-ext-gnomekeyring`、`dde-widgets`
  （均加 alias throw）。
- ✅ NixOS 模块清理：移除已删包的引用，默认 session 改为 `treeland`，
  `deepin-anything` 模块已启用（2026-10-15，见下）。

> `packages/apps/` 的 11 个应用已于 2026-10-15 全部升级到 Qt6 并验证
> `nix build` 通过（详见 `docs/development.md` 的 Maintained packages 表与
> 升级日志）。本节此前只写 `deepin-terminal` 一个应用，已过期。
- ⏳ 阻塞项：无（所有已记录 blocker 均已解决）。
- 🖥️ VM 调试：DDM + Treeland 启动链路已打通（0 failed units），登录画面
  待最后一项 output enable 问题解决。见第 9 节。

详见 `docs/development.md` 的「Maintained packages」表。

## 4. 质量基线与参考代码

**唯一基准是 nixpkgs 移除 DDE 前的最后一个版本**，就在本仓库 git 历史里：

```bash
git show f81b263cd0688a2eed1e29920e655999672f1a6d:<path>   # 取基线文件
git ls-tree -r --name-only f81b263                          # 列基线清单
```

三方参考项目（`nixos-unstable-dde-25-flake`，ktechmidas 的 DDE 25 flake）
已于 2026-10-15 删除：Qt6 升级时照抄它导致过一批路径修复回归（详见
development.md「升级时不要照抄三方 flake」），**不要再引入**。

需要看上游源码时，**按需** clone 到 `dde/src/<repo>`（不要预先批量 clone）：

```bash
git clone --filter=blob:none https://github.com/linuxdeepin/<repo> dde/src/<repo>
```

`dde/src-dl/` 另有 `fetch.py <repo> <version>` 可下载指定 tag 的源码包。

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
3. 用 `git show f81b263:<path>` 对比 nixpkgs 基线的定义与 patch，判断改动
   合理性；需要上游源码时再 clone 到 `dde/src/<repo>`。
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
3. ~~`deepin-anything`~~ **已完成（2026-10-15）**：升级到 7.1.0，userspace
   与内核模块均打包并验证通过，NixOS 模块已启用。见第 3 节与
   `docs/porting/`。原计划的"迁 Qt6 + 打包内核模块"实际上上游 7.x 已原生
   支持 Qt6（`find_package(QT NAMES Qt6 Qt5)`），Qt5 依赖只需在包定义里换成
   Qt6 即可；内核模块拆成独立包 `deepin-anything-module`。
4. **重建 VM 复测 treeland output**（见第 9 节第 1 条）：`vm/result` 还停在
   treeland 0.10.0，而 0.11.0 已包含当年判定缺失的 `enable()` 调用。
   2026-10-15 已 `nix build .#nixosConfigurations.vm.config.system.build.vm`
   并更新 `vm/result`（现指向含 0.11.0 的新镜像），但**尚未在图形环境里跑起来
   复测**：沙箱无 KVM，纯 TCG 引导全桌面极慢且无 GL render node
   （`-display gtk,gl=on` / `egl-headless` 都不可用）。待有 KVM/GL 的环境再跑一遍，
   若输出正常即可从"已知限制"里删掉。`vm/run-headless.sh` 是为此写的
   无 GL 启动脚本（改用 `-vga virtio -display none`，保留 hostfwd 2222→22），
   在有 KVM 的机器上可直接用。
5. **跨包 Exec 路径已全量扫过一遍**（2026-10-15）：所有包当前解析产物的
   `Exec=`/`ExecStart=` 均不再指向 `/usr`（`=/usr/bin/false` 的 systemd 委派
   占位符除外）。要复查用：解析各包产物路径后
   `grep -rn "^ExecStart=.*/usr/\|^Exec=.*/usr/" <out>/{lib,share}/systemd <out>/share/dbus-1`。
   注意**别扫 /nix/store 里所有同名目录** —— 旧构建会残留旧路径，必须只用当前
   flake 解析到的那一个（`nix build .#<pkg> --print-out-paths --no-link`）。

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

1. **output 未 enable（可能已随 treeland 0.11.0 修掉，待复测）**：treeland 日志
   `Temporarily disabled output during initial scan "Virtual-1"` 后无
   `Enabled output`。DConfig `org.desktopspec.ConfigManager` 已注册、
   `org.deepin.dde.treeland.output` 资源可读（width/height/x 均为默认 0，
   即无已保存模式），但 `restoreInitialOutputConfiguration` 未把 output 重新
   enable，QEMU 里仍显示 `Display output is not active`。
   **2026-10-15 复核**：该结论是在 treeland **0.10.0** 上得出的（`vm/result`
   仍链到 `treeland-0.10.0`，VM 于 10-12 构建）。已对 `dde/src-dl/treeland-0.11.0`
   源码逐处核对，确认 0.11.0 已修好此问题：
   - `src/seat/helper.cpp:3971` `restoreExtensionModeFromConfig()` 里对每个
     output **无条件调用 `outputObject->enable()`**，注释写明
     "enabling an output must not depend on that initialization succeeding"；
   - 启动路径 `helper.cpp:743` 调 `restoreInitialOutputConfiguration()`
     （定义在 `:4068`），其默认分支（`singleOutputId` 为空且非 copy-mode）
     在 `:4101` 落到 `restoreExtensionModeFromConfig()` —— 正是当年判定缺失
     的那一步。
   所以**无需改源码**；已验证 `vm/flake.lock` 重新生成后，VM toplevel 解析到
   `treeland-0.11.0.drv`（不再是 0.10.0），并已 `nix build` 出新 VM 镜像、更新
   `vm/result`（旧镜像停留在 10-12）。**剩余动作只有"在带 KVM/GL 的环境里跑起来
   看 output 是否亮"** —— 本沙箱无 KVM（纯 TCG 太慢）、无 GL render node
   （`gtk,gl=on` 与 `egl-headless` 都起不来），故未完成这一步复测。
2. **登录界面缺默认头像**：`QtIcon: Cannot open:
   file:///var/lib/AccountsService/icons/default`。宿主 deepin 有该 symlink
   （指向 `icons/animal/raccoon.png`），VM 缺失。
3. **treeland unit 与宿主差异**：VM 由 NixOS 生成，`NoNewPrivileges=true`
   （宿主为 `false`，注释说明 NVIDIA setuid 需要）；宿主另有
   `StandardOutput=null`、`AmbientCapabilities=CAP_IPC_OWNER` 等。若后续
   NVIDIA/真实硬件异常，优先对齐这些项。
4. **DSG_DATA_DIRS 噪声日志**：`dde-dconfig-daemon` 报大量
   `Can't load meta file from local prefix: ""`。**2026-10-15 复核：已不是配置
   问题** —— `dde-app-services` 的 unit 里 `DSG_DATA_DIRS` 已正确指向
   `/run/current-system/sw/share/dsg`，模块也链接了 `/share/dsg`；噪声是因为
   tray-loader/dock/network 等**消费方 app 的 meta 尚未安装**（对应包未进仓库）。
   属于"等包补齐"而非"可清理"，不必再动。
