# 上游 patch 回传评估

对仓库里**全部对上游源码的改动**做一次分类：**哪些是上游 bug（值得提 issue/PR），  
哪些只是 Nix 打包适配（不该提上游）**。

覆盖面：

- `packages/**/*.patch` 共 **16 个文件**（第 A、B 节）；
- `packages/**/default.nix` 里的 `substituteInPlace` / `--replace` 共 **207 条**  
  （第 C 节）。

判断标准只有一条：

> 这个改动放在 **FHS 发行版**（Debian / Arch / Fedora，`CMAKE_INSTALL_PREFIX=/usr`）  
> 下是否也是正确的？
>
> - 是 → 上游 bug，可以提。
> - 只在 Nix 的 store 布局下才成立 → 打包适配，不要提。

> ⚠️ **只扫 `*.patch` 会漏掉最重要的那组 bug** —— 绝对 `install(... DESTINATION /…)`  
> 在本仓库主要用 `substituteInPlace` 修（见 C1）。

---

## A. 真正适合提上游（2 组，共 3 个文件）

### A1. `dde-network-core`: `install(FILES ... DESTINATION /etc/...)` 硬编码绝对路径

> 这是 C1 组里唯一"碰巧用 patch 而非 substituteInPlace 修"的一处；  
> 完整清单与共性分析见 **C1**。此处单列是因为它是 patch 文件里唯一的上游 bug。

- 文件：`packages/core/dde-network-core/fix-paths.patch`（该 patch 三条改动里的第 3 条）
- 位置：`network-service-plugin/CMakeLists.txt:80`
- 上游现状（2.0.103）：


  ```cmake
  install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/system/deepin.dde.daemon.conf
          DESTINATION /etc/NetworkManager/conf.d/)
  ```
- **为什么是 bug**：CMake 的 install DESTINATION **必须相对** `${CMAKE_INSTALL_PREFIX}`。  
  写死 `/etc` 会**吞掉 DESTDIR**，任何做 staged install 的打包方式  
  （Debian `dh_install`、Arch `make DESTDIR=… install`、Nix）都会把文件装到  
  宿主机的 `/etc`（或直接失败）。这是跨发行版的通用问题。
- **上游应该改成**：`${CMAKE_INSTALL_SYSCONFDIR}/NetworkManager/conf.d/`  
  （或 `${CMAKE_INSTALL_FULL_SYSCONFDIR}`，视 install 语义）。
- **建议**：开 issue + PR。改动一行，风险低，理由充分。

### A2. 同一 patch 里的 `WaylandClientPrivate`

- 位置：`dock-network-plugin/CMakeLists.txt:39`
- 上游：`find_package(${QT_NS} COMPONENTS Core Widgets DBus Network WaylandClient LinguistTools)`
- 修复后：补上 `WaylandClientPrivate`
- **为什么可能是 bug**：代码如果用了 `WaylandClientPrivate` 的私有头却不在  
  `find_package` 里声明的组件，那**上游环境能过只是碰巧**（Qt 打包方式不同，  
  私有头恰好可见）。补声明是更严谨的做法，且不影响 FHS 构建。
- **建议**：可以顺手并在 A1 的 PR 里，或在 issue 里提一句。  
  但如果上游明确依赖"私有头不需声明"的既有行为，可能被拒 —— 优先 A1。

### A3. `dde-derived` 的 `.pc.in`（如上游愿意接受"支持绝对 install dir"）

> 见 B 组说明。B 组整体是 Nix 适配，**但** `.pc.in` 那一半可以换一种  
> 上游更可能接受的写法（用 `@CMAKE_INSTALL_FULL_*@`），若上游想支持  
> 可重定位/绝对 install dir 的场景，这是一个真实的健壮性改进。  
> **不作为主要建议**，仅备选。

---

## B. Nix 打包适配 —— 不要提上游（主体，13 个文件）

### B1. `.pc.in` / `.pri.in` 的"双前缀"补丁（8 个文件）

- 文件：
  - `library/dtkcore/{fix-pkgconfig-path,fix-pri-path}.patch`
  - `library/dtkgui/{fix-pkgconfig-path,fix-pri-path}.patch`
  - `library/dtkwidget/{fix-pkgconfig-path,fix-pri-path}.patch`
  - `library/dtkdeclarative/{fix-pkgconfig-path,fix-pri-path}.patch`
  - `library/deepin-pdfium/fix-pc-double-prefix.patch`
  - `library/docparser/fix-pc-double-prefix.patch`
  - `library/udisks2-qt6/fix-pc-double-prefix.patch`
- 根因（已实测确认）：
  - 上游 `*.cmake` 里 `set(LIBRARY_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}")`  
    —— 在 **FHS** 下 `CMAKE_INSTALL_LIBDIR` 是**相对值** `lib`，  
    所以 `.pc.in` 里 `libdir=${prefix}/@LIBRARY_INSTALL_DIR@`  
    = `/usr/lib`，**完全正确**。
  - 在 **Nix** 下，cmake 的 install dir 被设成**绝对 store 路径**，  
    于是 `${prefix}/绝对路径` → `/nix/store/.../nix/store/...` 双前缀。
  - 所以 patch 把 `${prefix}/` 前缀去掉，产物才正确  
    （实测 dtkcore 产物 `libdir=/nix/store/...-dtkcore-6.7.50/lib`）。
- **结论**：**上游写法在 FHS 下是对的**，No-op 于上游。不提。
- 备注：`dtkdeclarative` 的 `.pc.in` 只 patch 了 `libdir`，`includedir` 仍带  
  `${prefix}/include/...`，因为那部分是字面量而非变量，不受影响。

### B2. `dde-appearance/no-fakewm.patch`

- 删掉 `add_subdirectory(fakewm)`、X11 的 `com.deepin.wm.service`、  
  `dde-fakewm.systemd` 安装。
- **性质**：本移植只跑 Wayland（treeland），主动丢弃 X11 组件。  
  上游要同时支持 X11，**不会接受删除**。
- **结论**：不提。这是移植取舍，不是 bug。最多在 issue 里说明"NixOS 端口  
  不构建 X11 组件"，但不是上游要改的事。

### B3. `dde-session-shell/0001-skip-greeter-and-tests.patch`

- 去掉 `pkg_check_modules(Greeter REQUIRED liblightdm-qt6-3)`、greeter 目标  
  与 install 规则、tests 子目录。
- **性质**：因为本移植用 **ddm（SDDM fork）** 而非 lightdm，且 nixpkgs 没有  
  `liblightdm-qt6-3` 的 Qt6 绑定。
- **结论**：不提。属于"这个发行版不用 lightdm"的打包决策。  
  上游的 greeter 本身没坏。

### B4. `dde-file-manager/0001-drop-ocr-extractor-plugin.patch`

- 删掉 `add_subdirectory(ocr-extractor)`。
- **性质**：ocr 插件依赖 `dtk6ocr`，而该上游仓库（`linuxdeepin/dtk6ocr`）  
  **已不存在**。
- **结论**：这不是"我们改错了"，而是**上游自己引用了一个消失的依赖**。  
  **不适合提 PR 删除**（我们无权替上游决定砍功能）；但**可以开 issue 提醒**  
  「`dde-file-manager` 的 ocr-extractor 依赖 `dtk6ocr`，该仓库已 404，  
  从源码构建会失败」—— 这属于**上游需要知道的信息**。

### B5. `go-package/dde-daemon/0001-dont-set-PATH.patch`

- 删掉 `dde-system-daemon/main.go` 与 `grub2/modify_manger.go` 里  
  `os.Setenv("PATH", "/usr/local/sbin:...:/bin")` 的兜底。
- **性质**：Nix 下 PATH 由 wrapper 正确注入，硬编码兜底反而**覆盖并破坏**注入的  
  PATH。但反过来看，上游在**无 PATH 的 dbus 启动环境**下需要这个兜底  
  （这是上游刻意加的 comment："fix no PATH when was launched by dbus"）。
- **结论**：不提。这是 Nix 包装模型与上游假设的冲突，**双方各自都是对的**。  
  （若有条件，更上游友好的做法是让它读 `$PATH` 而不是写死，  
  但那是"改进建议"而非 bug，优先级最低。）

---

## C. substituteInPlace 类（不是 .patch 文件，但同样要审）

全仓库 `default.nix` 里共 **207 条** `--replace` / `--replace-fail`。  
逐条按"新值形式"分类：

| 类别                                                            | 条数  | 性质            |
| ------------------------------------------------------------- | --- | ------------- |
| 新值 = Nix store / 运行时路径（`$out`、`${...}`、`/run/current-system`） | 173 | Nix 适配（绝大多数）  |
| 新值为空（删整段）                                                     | 7   | 多为禁用功能 / 编译适配 |
| 从 `/usr` 改成别的绝对路径                                             | 1   | 见 C3          |
| 其它（去掉 `/usr` 前缀、改成裸命令名等）                                      | 26  | 混合，见下         |

其中**真正属于上游 bug 的，是 C1 与 C2**：

### C1.（新发现，最重要）绝对 `install(... DESTINATION /xxx)` —— 吞掉 DESTDIR

这是 A1 的**同类问题**，散落在多个包，且**都用 substituteInPlace 修**（不是 patch），  
所以只看 `*.patch` 会漏掉。全部清单：

| 包                   | 上游写法                                      | 位置                                           |
| ------------------- | ----------------------------------------- | -------------------------------------------- |
| `dde-network-core`  | `DESTINATION /etc/NetworkManager/conf.d/` | `network-service-plugin/CMakeLists.txt:80`   |
| `dde-file-manager`  | `DESTINATION /etc/systemd/system/`        | `src/services/CMakeLists.txt:11`             |
| `dde-file-manager`  | `DESTINATION /etc/udev/rules.d`           | `src/services/diskencrypt/CMakeLists.txt:33` |
| `dde-session`       | `DESTINATION /etc/X11/Xsession.d/`        | `misc/CMakeLists.txt`                        |
| `dde-session`       | `DESTINATION /etc/profile.d`              | `misc/CMakeLists.txt`                        |
| `dde-session`       | `DESTINATION /etc/xdg/autostart/`         | `tools/dde-oom-score-adj/CMakeLists.txt`     |
| `dde-session-shell` | `DESTINATION /var/lib/dde-session-shell/` | `CMakeLists.txt`                             |

- **为什么是 bug**：CMake `install()` 的 `DESTINATION` 若为绝对路径，会**完全忽略  
  `CMAKE_INSTALL_PREFIX` 和 DESTDIR**，直接写进运行构建机器的真实目录。任何  
  staged install（Debian `dh_install`、Arch `make DESTDIR=…`、Nix）都会失败或  
  污染宿主机。**跨发行版通用问题。**
- `dde-session` 的注释（我们自己写的）一句话点透：  
  "Absolute DESTINATION ignores CMAKE_INSTALL_SYSCONFDIR."
- **上游应改成**：`${CMAKE_INSTALL_SYSCONFDIR}/...`、`${CMAKE_INSTALL_FULL_…}`  
  或（systemd/udev 这类）相对 `${CMAKE_INSTALL_PREFIX}` 的路径。
- **建议**：每个仓库各提一个 PR（一行改动）。这是**本仓库回传上游价值最高的一组**，  
  比 A1 那条更成体系（涉及 4 个仓库、7 处）。

### C2.（新发现）Qt ≥ 6.11 编译兼容：`QString::arg(char16_t, …)` 重载被移除

- 包：`dde-file-manager`，文件  
  `src/plugins/filemanager/dfmplugin-disk-encrypt-entry/utils/encryptutils.cpp:691`
- 上游写法：`QString("_%1").arg(ch.unicode(), 2, 16, QChar('0'))`
- 修复：`arg(static_cast<uint>(ch.unicode()), 2, 16, QChar('0'))`
- **为什么是 bug**：Qt 6.11 移除了 `QString::arg()` 的 `char16_t` 重载，  
  `ch.unicode()` 返回 `char16_t`，于是**任何用 Qt ≥ 6.11 构建的人都会编译失败**  
  （与发行版无关）。已核对：**上游最新 `6.6.6+91` 里仍是旧写法，未修**。
- **建议**：提 issue/PR（附带"Qt 6.11 移除该重载"的依据）。风险极低。

### C3. `/usr/bin/sudo` → `/run/wrappers/bin/sudo`（dde-file-manager）

- 纯 NixOS 特有（NixOS 的 setuid 程序在 `/run/wrappers/bin`）。
- **结论**：不提。上游写 `/usr/bin/sudo` 在 FHS 下正确。

### C4. 其余 26 条"其它"类 —— 逐条看过，均不提上游

- **去掉 `/usr` 前缀 / 改裸命令名**（如 `'/usr/lib/qt6/bin/lrelease' -> 'lrelease'`、  
  `'/usr/sbin/alsactl' -> 'alsactl'`、`'/usr/bin/getconf' -> 'getconf'`、  
  `'/usr/bin/deepin-compressor' -> 'deepin-compressor'`）：改为依赖 `PATH`  
  查找，是 Nix 包装模型的做法；上游写绝对路径在 FHS 下可用。  
  **不提**（唯一可议：上游若愿意改成"优先 PATH、回退绝对路径"会更通用，  
  但属低优先级建议）。
- **`/usr/share/...` → `share/...`（相对）、`@CMAKE_INSTALL_PREFIX@/@X@ -> @X@`**  
  （dde-control-center 2 条、dde-shell 3 条）：与 B1 双前缀同源，**Nix 适配，不提**。
- **`/usr/share/zoneinfo` → `/etc/zoneinfo`**（dde-control-center）：  
  NixOS 把 tzdata 放在 `/etc/zoneinfo`。**纯 NixOS，不提**。
- **`"/usr/share/dsg/icons/" -> '"'`、`"/usr/share/dde-appearance/ -> '"'` 等**：  
  把"编译进去的绝对前缀"改成运行时拼接，**Nix 适配，不提**。
- **`'sudo cp' -> 'cp'`（deepin-gettext-tools，install 脚本）**：  
  上游安装脚本里用 `sudo` 本就多余（install 阶段不应 sudo）。算"构建脚本坏味道"，  
  **可作极低优先级建议**，不单独提。
- **`ch.unicode` 之外的编译修复**（`#include <QGSettings/QGSettings>` → `<QGSettings>`、  
  `-pie` 相关、`-Werror` 移除、`static_cast` 等）：属"新工具链/新 Qt 兼容"，  
  其中 C2 最典型；其余多为 Nix 环境特有或与上游暂未遇到的版本组合有关。  
  **逐条评估后只有 C2 明确值得提**。

---

## 汇总表

| #      | 来源                                              | 类型         | 提上游？               | 备注                            |
| ------ | ----------------------------------------------- | ---------- | ------------------ | ----------------------------- |
| **C1** | `substituteInPlace`（4 仓库 7 处）                   | **上游 bug** | ✅ **建议各提 PR**      | 绝对 `DESTINATION` 吞掉 DESTDIR   |
| A1     | `dde-network-core/fix-paths.patch`              | 上游 bug     | ✅（同 C1，合并提）        | 与 C1 第一条是同一处                  |
| **C2** | `dde-file-manager` `ch.unicode()`               | **上游 bug** | ✅ **建议提 issue/PR** | Qt ≥6.11 移除 `arg(char16_t,…)` |
| A2     | `dde-network-core` 第2条                          | 健壮性        | ⚠️ 可附带             | 补 `WaylandClientPrivate`      |
| B1     | `dtk{core,gui,widget,declarative}/{pc,pri}` 8 个 | Nix 适配     | ❌                  | FHS 下原写法正确                    |
| B1'    | `{deepin-pdfium,docparser,udisks2-qt6}/pc` 3 个  | Nix 适配     | ❌                  | 同上                            |
| B2     | `dde-appearance/no-fakewm.patch`                | 移植取舍       | ❌                  | 主动弃 X11                       |
| B3     | `dde-session-shell/...skip-greeter...patch`     | 移植取舍       | ❌                  | 不用 lightdm                    |
| B4     | `dde-file-manager/...drop-ocr...patch`          | 上游依赖 404   | ⚠️ **可提 issue**    | `dtk6ocr` 仓库不存在               |
| B5     | `dde-daemon/0001-dont-set-PATH.patch`           | 模型冲突       | ❌                  | 双方各自正确                        |
| C3     | `sudo` wrapper 路径                               | NixOS 特有   | ❌                  | —                             |
| C4     | 其余 `substituteInPlace`                          | Nix 适配     | ❌                  | 无 `/usr`/store 布局所致           |

**结论（含 substituteInPlace）**：

- **值得提 PR/issue 的共 3 组**：
  1. **C1 + A1**：绝对 `install(DESTINATION /…)` 吞掉 DESTDIR ——  
     涉及 `dde-network-core`、`dde-file-manager`、`dde-session`、  
     `dde-session-shell` 共 **4 个仓库、7 处**。这是最成体系、最该提的一组。
  2. **C2**：`dde-file-manager` 的 Qt ≥6.11 `arg(char16_t,…)` 兼容 —— 上游未修。
  3. **B4（issue only）**：`dde-file-manager` 的 ocr-extractor 依赖已 404 的 `dtk6ocr`。
- **其余（16 个 patch 中的 13 个 + 207 条替换中的绝大多数）都是 Nix 打包适配**，  
  回传上游会被视为 No-op 或倒退。

---

## 建议行动

1. **提 PR（价值最高，4 个仓库）**：把绝对 `DESTINATION` 改为  
   `${CMAKE_INSTALL_SYSCONFDIR}/…` 等相对形式：
   - `linuxdeepin/dde-network-core` — `network-service-plugin/CMakeLists.txt:80`
   - `linuxdeepin/dde-file-manager` — `src/services/CMakeLists.txt:11`、  
     `src/services/diskencrypt/CMakeLists.txt:33`
   - `linuxdeepin/dde-session` — `misc/CMakeLists.txt`、  
     `tools/dde-oom-score-adj/CMakeLists.txt`
   - `linuxdeepin/dde-session-shell` — `CMakeLists.txt`（conf 文件 DESTINATION）
2. **提 PR/issue**：`linuxdeepin/dde-file-manager` —  
   `encryptutils.cpp:691` 的 `ch.unicode()` 加 `static_cast<uint>`，  
   说明 Qt 6.11 移除了 `QString::arg(char16_t,…)` 重载。


1. **提 issue**：`linuxdeepin/dde-file-manager` — ocr-extractor 依赖的  
   `dtk6ocr` 仓库已不存在，源码构建失败。
2. **其余不提。** 可另开一个"meta"issue 汇总"硬编码 `/usr`、绝对 DESTINATION、  
   FHS 假设"的长期建议，但不阻塞当前移植。
