# AGENTS.md

面向 AI 编码代理（及人类维护者）的仓库工作指南。详细背景见
`docs/AI-GUIDE.md`，包维护清单与升级日志见 `docs/development.md`。

> **前提**：本仓库大量依靠 AI 代理维护，改动**不保证**达到合入 nixpkgs 的
> 标准（`meta` 正确性、许可证、审查深度、能否上游化都不做承诺），不应直接
> 原样回传上游；patch 的「上游 bug / Nix 打包适配」分类见
> `docs/upstream-patches.md`。另外 **DDE 移植仍在进行中、当前不可用**：
> `services.desktopManager.deepin` 起不来完整桌面，只当作移植工作台用。

## 项目定位

把 DDE（Deepin Desktop Environment）在 NixOS 上重新跑起来，并逐步把整套组件
迁移到 Qt6。窗口管理器目标为 **treeland**（Wayland compositor，基于
QtQuick + vendored waylib/wlroots）。

源码基线：包定义同步自 nixpkgs 移除 DDE 前的 commit `96e751adaf2f`，NixOS
模块来自 `15a586f29d59`。之后在此之上做 Qt6 迁移。

## 常用命令

```bash
# 构建单个包（不链接，只验证）
nix build .#<pkg> --no-link

# 构建全部（flake 暴露 packages.<system>.* = 所有 derivation）
nix flake show

# 取上游最新 tag
gh api repos/linuxdeepin/<repo>/tags --jq '.[].name'

# 取源码 SRI hash（fetchFromGitHub 用 archive/<rev>.tar.gz，不是 refs/tags）
nix-prefetch-url --unpack https://github.com/<owner>/<repo>/archive/refs/tags/<ver>.tar.gz
nix hash to-sri --type sha256 <base32>

# VM 集成测试（DDM + Treeland）
cd vm && nix build --no-write-lock-file --impure && ./result/bin/run-nixos-vm
```

## 目录布局

```
flake.nix            # overlay 注入 pkgs.deepin + nixosModules + 每系统别名
packages/default.nix # 包 scope 唯一维护清单（未升级的一律注释）
packages/library/    # DTK + 支撑库（Qt6）
packages/core/       # 核心组件（dde-session、dde-shell、treeland、ddm…）
packages/apps/       # 桌面应用
packages/artwork/    # 主题/图标/壁纸/头像（纯数据）
packages/go-package/ # Go 服务（dde-daemon、startdde…）
packages/tools/      # 构建/工具
nixos-modules/deepin/# NixOS 模块
docs/                # development.md（维护状态）+ AI-GUIDE.md（详细指南）
vm/                  # 虚拟机测试 flake
dde/                 # 上游源码 clone 与按需下载（.gitignore 忽略，不提交）
```

## 关键约定

### 命名
- DTK 库「去 6 后缀」：`dtkcore`/`dtkgui`/`dtkwidget`/`dtkdeclarative`/
  `dtksystemsettings`/`dtklog` 都是 **Qt6** 版本，Qt5 已删除。

### 维护策略
- `packages/default.nix` 只启用「已升级并构建通过」的包，其余注释。
  升级一个 → 验证一个 → 启用一个。
- 升级/新增包后**必须**同步更新 `docs/development.md` 的维护表 + 升级日志。
- **质量基准**：以 nixpkgs 最后一个含 DDE 的版本
  `f81b263cd0688a2eed1e29920e655999672f1a6d` 为基准审查 diff 合理性。
  基线就在本仓库 git 历史里，`git show f81b263:<path>` 直接取基线文件。

### 审包四步法
升级/审查每个包时：
1. **需要看代码时**才在 `dde/src/<repo>` 用 `git clone --filter=blob:none`
   带完整历史 clone 源码，用 git log/tag 对比新旧版本差异。
2. 检查硬编码路径（尤其 `/usr`），确认每处是否需要替换（Debian 专属工具、
   不被 Makefile 安装的 debian/ 目录等可有意保留）。
3. 检查编译输出：gsettings/dconfig 配置、dbus service、systemd unit、polkit、
   udev 规则、新建用户、cmake 模块——凡影响 NixOS 模块的需特别标注。
4. 每个包写独立移植文档 `docs/porting/<包名>.md`，并更新 development.md。

### 路径修复方式（优先级从高到低）
1. **patch/diff 文件**（`patches = [ ./xxx.patch ]`），删代码块、改逻辑用这个。
2. **substituteInPlace 精确替换**，逐文件列出 + `--replace-fail`。
3. **避免** `find -exec sed`、大范围 sed 正则、`grep -rl` 循环——会误伤
   debian/rpm/archlinux 打包目录和测试文件。

### 构建验证
- 任何包改动后跑 `nix build .#<pkg> --no-link` 确认通过，再提交。
- 报 `CMake 4.x -pie`、`.pc` double-prefix、硬编码 `/usr/...` 等问题时，先查
  `docs/development.md`「Gotchas」和 `docs/AI-GUIDE.md`「常见坑」。

### 提交规范
中文团队 Conventional Commits 风格，信息从简：

```
<type>(<scope>): <中文简述>
```

type 常用：`feat`/`fix`/`refactor`/`remove`/`chore`；scope 用包名或目录。
（详细示例见 `docs/AI-GUIDE.md` 第 7 节。）

提交时**只 add 自己的改动**（`git status` 确认），不要混入其他 agent
并行修改的文件；GPG 超时可用 `--no-gpg-sign`。

## 常见坑（速查）

- **fetchFromGitHub hash**：抓的是 `archive/<rev>.tar.gz`，不是 `refs/tags`。
- **CMake 4.x `-pie`**：shared lib 链接报 `undefined reference to main`，patch 掉 `-pie`。
- **硬编码 FHS 路径**：deepin 源码常写 `/usr/share/...`、`/usr/bin/...`，
  需 `substituteInPlace` 替换为 `${pkg}/share/...` 或 `/run/current-system/sw/...`。
- **`finalAttrs` 下不能裸用 `src`**：phase 里用 `finalAttrs.src.name`。
- **treeland/ddm 是上游 systemd unit 挂载**（`systemd.packages`），linked unit
  不自动获得 NixOS 默认 PATH 注入，需显式 override（见 `deepin.nix` 的
  `systemd.services.treeland.path`）。

完整列表见 `docs/development.md`「Gotchas」。

## 当前状态与待办

- **library 已审查完**：DTK 7 库 + 非 DTK 11 库全部 Qt6 最新版，文档在
  `docs/porting/dtk.md`、`docs/porting/libraries.md`。
- **go-package 已审查完**：5 个 Go 服务版本最新，硬编码路径已按基准改为
  patch + 精确替换，文档在 `docs/porting/go-packages.md`。
- **packages/core/ 审查中**：按四步法逐个审查（deepin-service-manager、
  dde-session 系、dde-shell、treeland、ddm 等）。
- 核心组件、Go 服务、artwork 已大部分升级到 Qt6 并构建通过。
- **VM 登录链路已打通**（DDM + Treeland 0 failed units），treeland 0.11.0
  的 output enable 问题已于 2026-10-15 实机复测通过（宿主 KVM + AMD GPU + GL），
  详见 `docs/AI-GUIDE.md` 第 9 节。
- `deepin-anything` 模块已接好，`services.deepin25.deepin-anything.enable`
  默认 false（userspace + 内核模块 + 3 个 unit 均在，详见
  `docs/porting/tools.md`）。
- **Cutefish 是第二套桌面（独立于 DDE）**：`packages/cutefish/`（`lib.fix`
  属性集，不进 DDE scope）+ `nixos-modules/cutefish/` +
  `vm-cutefish/`。17 个包全部构建通过，`services.desktopManager.cutefish.enable`
  一条即可起整套（默认带 `cutefish-dm`：greeter 用户、两个 PAM 栈、
  `display-manager.service` 别名）；VM 镜像构建通过，实机启动未验（需宿主
  GPU 的 DRM/EGL）。详见
  `docs/porting/cutefish-survey.md`（总览与进度）、
  `cutefish-toolkit.md`（Skia 与 toolkit）、`cutefish-apps.md`（L3 应用）、
  `cutefish-core.md`（会话、后台服务、显示管理器）。
