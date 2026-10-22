# Handoff：让沙箱外 AI 继续调试 deepin-anything / DDE-on-NixOS

> 把下面「提示词正文」整段复制给沙箱外的 AI 即可。它自带全部上下文，
> 不依赖任何历史对话。

---

## 提示词正文

你是一名 Nix/NixOS 打包与桌面移植工程师。请接手一个真实仓库的后续调试工作。

### 0. 环境与仓库

- 仓库：`dde-nixos`，路径 `<REPO>`（请让用户告诉你绝对路径；下称 `$REPO`）。
- 目标：nixpkgs 移除 DDE 后，把 `pkgs/desktops/deepin` 与对应 NixOS 模块接回来，
  整体迁移到 **Qt6**，未来窗管是 **treeland**（Wayland 合成器）。
- 分支：`main`。质量基线提交：`f81b263cd0688a2eed1e29920e655999672f1a6d`。
- 仓库的包升级工作已全部完成，没有其他 agent 在并行改动，你可以直接改
  `packages/` 下任何目录。

### 1. 先读这几份文档（按顺序）

1. `docs/AI-GUIDE.md` —— 给 AI 的 SOP、当前进度清单、待办列表。
2. `docs/development.md` —— Maintained packages 表 + Upgrade log + Gotchas。
3. `docs/porting/tools.md` —— **本任务主角 deepin-anything 的完整记录**。
4. `AGENTS.md` —— 仓库总约定。

### 2. 当前状态（截至提交 `96742c5`）

**已完成**：
- `packages/apps/` 下 11 个应用全部 Qt6 化，`nix build` 通过。
- `deepin-anything` 从 `6.2.10`(Qt5) 升级到 `7.1.0`(Qt6)，构建通过。
- 新增 `deepin-anything-module` 内核模块包（`vfs_monitor.ko`），构建通过。
- NixOS 模块 `nixos-modules/deepin/deepin-anything.nix` 已接好，
  **默认不启用**（`services.deepin25.deepin-anything.enable`，默认 false）。
- VM toplevel 端到端构建通过；开启时能正确引入 userspace 包、内核模块和 3 个 unit。

**未完成 / 待办**（你的工作重点）：
1. ~~**VM 图形复测（最高优先级）**~~ **✅ 已完成（2026-10-15）**：treeland
   0.11.0 的 output enable 问题已实机复测通过（宿主 KVM + AMD GPU + GL，
   `egl-headless,gl=on`）。证据：0 failed units、`connector Virtual-1:
   Requesting modeset`、GLES2 渲染器创建成功、当年 0.10.0 的
   `Temporarily disabled output during initial scan` 不再出现、
   `Output "Virtual-1" does not support gamma LUT!`（仅 output 已 enable 时
   才打印）、`switch_to_user "test"` + 用户会话建立。详见
   `docs/AI-GUIDE.md` 第 9 节。
2. **复核遗留**：`packages/default.nix` 里所有包都已启用（没有注释掉的包），
   包升级阶段已完成。可再通读一遍 `docs/` 里标着「待复测 / 待办」的条目，
   确认是否还有真实遗留。

### 3. 构建与验证命令（务必按此顺序）

```bash
# 语法检查（改完 .nix 立刻跑，很快）
nix-instantiate --parse <file.nix>

# 单包构建，务必用 --print-out-paths 拿产物路径
nix build .#<pkg> --print-out-paths --no-link

# 审计产物里的硬编码 /usr 路径（NixOS 无 /usr，这类是"必然失败"）
out=$(nix build .#<pkg> --print-out-paths --no-link)
grep -rl "/usr/" "$out"

# VM 配置求值（vm 是独立 flake，必须在 vm/ 里跑）
cd "$REPO/vm"
nix eval --raw .#nixosConfigurations.vm.config.system.build.toplevel.drvPath
# 检查 toplevel 引用了哪些包（递归！）：
nix-store -qR <toplevel.drv> | grep -iE '<pkg>'
```

**关键陷阱**：
- **取产物路径必须 `--print-out-paths`**，`--print-build-logs` 不打印 out 路径。
- 扫 store 里包产物时，**别用 `ls -dt /nix/store/*<name>-*`**（会命中历史同名构建，
  假阳性）。只认 `nix build .#<pkg> --print-out-paths` 给的当前路径。
- `packages/tools/deepin-anything/default.nix` 里 hash 是
  `sha256-nj8I4hm/OyfMNq7PmX3XlRIbYSvvFGylpBHbrChqa+Q=`。

### 4. Git 规范

1. commit 规范：`<type>(<scope>): <中文简述>`，body 可中英混排。
2. 一次提交只做一件事，`git add` 具体文件（不要 `git add -A`）。
3. `vm/flake.lock` 长期保持未提交（`vm/` 下另有本地脚本，也不提交）。
4. 本环境（原沙箱）`commit.gpgsign = true` 但**签名必然失败**（utime 限制），
   之前一直用 `--no-gpg-sign`。你那边若签名正常则改回正常签名。
5. 注释要精简（3-4 行内，只写"为什么"）；长篇论证写进
   `.workbuddy/memory/YYYY-MM-DD.md`，不要塞进源码。

### 5. 环境注意事项（沙箱特有，仅供对照）

- 默认 shell 是 fish：`for` 循环、`P=...` 赋值、双引号里的 `$` 都会报语法错。
  复杂命令一律 `bash -c '...'`。
- **utime 被拒绝**：任何"设置时间戳"操作会 EPERM。表现：`tar` 解压满屏
  「无法 utime」、`gpg` 无法签名。解压请用 python tarfile
  （仓库有现成脚本 `dde/src-dl/fetch.py`）。
- `/tmp` 不稳（mkdir 后目录会消失），临时文件写到工作区。
- 需要看上游源码时**按需 clone**（`git clone --filter=blob:none`），
  **不要预先批量 clone**。已下载的快照在 `dde/src-dl/`（被 .gitignore 忽略）。
  判断"包定义里的 patch 是否还命中"用 `dde/src-dl/check_replace.py`。
- 三方参考项目 `nixos-unstable-dde-25-flake` 已删除，**不要再去参考**。

### 6. 交付要求

- 改完代码要给出：改了什么文件、为什么、`nix build` / `nix eval` 的验证结果。
- 若验证涉及 VM，请说明是"源码级确认"还是"实机跑通"，不要混为一谈。
- 完不成或遇到阻塞，如实说明卡在哪一步、报了什么错，不要假装完成。

---

## （给用户的备注，不要复制给 AI）

- 提示词正文里的 `<REPO>` 若要让 AI 直接用，请替换为真实路径
  `/home/ut004971@uos/dde-nixos`。
- 仓库的包升级已全部完成，当前唯一"代码已就绪、只差实机验证"的项就是
  **跑 VM 看 treeland 画面**。沙箱外环境如果有 **KVM + GL**，
  这一步最有价值。
- 若外部 AI 还要继续做别的（例如把改动推上游 nixpkgs PR #257400），
  在提示词第 2 节"待办"里相应调整即可。
