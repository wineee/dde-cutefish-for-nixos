# AGENTS.md

面向 AI 编码代理（及人类维护者）的仓库工作指南。详细背景见
`docs/AI-GUIDE.md`，包维护清单与升级日志见 `docs/development.md`。

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
dde/                 # 参考实现（.gitignore 忽略，不提交）
```

## 关键约定

### 命名
- DTK 库「去 6 后缀」：`dtkcore`/`dtkgui`/`dtkwidget`/`dtkdeclarative`/
  `dtksystemsettings`/`dtklog` 都是 **Qt6** 版本，Qt5 已删除。
- 参考实现 `dde/nixos-unstable-dde-25-flake/` 用 `dtk6*` 命名，**不要照抄**。

### 维护策略
- `packages/default.nix` 只启用「已升级并构建通过」的包，其余注释。
  升级一个 → 验证一个 → 启用一个。
- 升级/新增包后**必须**同步更新 `docs/development.md` 的维护表 + 升级日志。

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

- 核心组件、Go 服务、artwork 已大部分升级到 Qt6 并构建通过。
- **VM 登录链路已打通**（DDM + Treeland 0 failed units），但登录画面仍有
  output 未 enable 问题，详见 `docs/AI-GUIDE.md` 第 9 节。
- `deepin-anything` 模块已注释（待内核模块 + 用户态工具）。
- `packages/apps/` 一批应用待升级（可能由其他 agent 并行负责，提交时不要碰
  其文件，注意 `git status` 只 add 自己的改动）。
