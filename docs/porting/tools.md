# 工具包移植文档

> `packages/tools/` 下的辅助工具。deepin-anything 是其中唯一有内核模块的包，
> 需要 userspace + kernel module 两个产物配合，**直接影响 NixOS 模块**。

## 概览

| 包 | 版本 | 产出 | 硬编码路径 | 模块影响 |
|---|---|---|---|---|
| dde-device-formatter | — | GUI 工具 | — | 无（随 dde-file-manager） |
| deepin-gettext-tools | — | 构建期 gettext 工具 | — | 无 |
| deepin-anything | 7.1.0 | 4 个二进制 + 2 systemd unit（1 system + 1 user）+ dconfig | unit `ExecStart=/usr/libexec/*`（postInstall 修） | deepin-anything.nix |
| deepin-anything-module | 7.1.0 | `vfs_monitor.ko` | Makefile `kdir` 用 `uname -r`（patch） | 同上，`boot.extraModulePackages` |

## deepin-anything

文件索引与内容搜索工具（对标 `locate`/`recoll`）。名字里带 "anything"
是指"什么都能搜"。架构分四层：

- **`deepin-anything-server`**（system, root）：监听内核 `vfs_monitor` 上报的
  文件变更，经 `/run/deepin-anything/event-dispatcher.sock` 分发事件。
- **`deepin-anything-logger`**（system, root）：从内核 netlink 读事件，写日志。
- **`deepin-anything-daemon`**（**user**）：按登录用户维护索引（`getuid` +
  检查登录 shell），消费事件。
- **`deepin-anything-searcher`**（CLI）：查询索引。

### 版本 6.2.10 → 7.1.0 的关键变化

1. **原生 Qt6**：顶层 `find_package(QT NAMES Qt6 Qt5)`，D-Bus 适配器按
   `QT_DESIRED_VERSION` 分支。**不需要改源码迁 Qt6**，包定义里用 Qt6 即可。
2. **重构**：原 `library`（C 库）拆成 `server`/`searcher`/`logger`/`dispatcher`，
   新增 `daemon`（C++）。
3. **新依赖**：`liblucene++`（全文索引）、Boost、spdlog。lucene++ 用本仓库
   已维护的 `lucenepp` override（供 dde-file-manager textindex 用）。
4. **去掉** udisks2-qt6 / polkit-qt 依赖（改用 GLib/GIO + libnl）。
5. **去掉 dbus**：不再产出 `com.deepin.anything` 的 dbus conf/policy，改用
   dconfig + systemd。
6. **修掉** 6.2.10 的 `install_targets` 未定义 bug（当时会导致 install 失败）。

### 硬编码路径

- unit 的 `ExecStart=/usr/libexec/deepin-anything-{server,logger,daemon}`
  → postInstall 改 `$out/libexec`。CMake 的 `install(DESTINATION libexec)`
  用相对路径，其余都落在 `$out` 下，无需 patch CMake。
- `deepin-anything-server.service`（system）**上游不安装**（注释
  "installed by debhelper"），由模块声明。

### 构建期问题

- **CMake 4.x**：`daemon`/`server` 的 `cmake_minimum_required(VERSION 3.1)`
  被拒 → `cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ]`。
- **GCC 16**：`pinyin_processor.cpp` 用 `std::wstring_convert`，在
  libstdc++ 15+ 已 deprecated，而项目 `-Werror` → 加
  `NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations"`。

### 内核模块（`deepin-anything-module`）

上游用 **DKMS** 分发（只装源码 + dkms.conf，由 DKMS 事后编译）。NixOS 不用
DKMS，改成独立的内核模块包：

- `setSourceRoot` 直接指向 `*/src/kernelmod`，只编模块源码。
- 上游 Makefile 的 `kdir := /lib/modules/$(shell uname -r)/build` 在沙箱里
  取不到 → patch 成 `kdir := $(KERNELDIR)`，由 makeFlags 传入。
- 上游 Makefile 只有 `all`/`clean`，没有 `modules_install`（stdenv install
  阶段需要）→ postPatch 追加一个目标转发到 kbuild。
- `hardeningDisable = [ "pic" ]`、`nativeBuildInputs = kernel.moduleBuildDependencies`、
  `installTargets = [ "modules_install" ]`，走标准 out-of-tree kbuild。
- **必须按运行内核构建**：模块里 `config.boot.kernelPackages.callPackage`
  ，产物落在 `<toplevel>/kernel-modules/lib/modules/<ver>/updates/vfs_monitor.ko.xz`。

> **`CONFIG_FSNOTIFY_BROADCAST` 是 UOS 内核补丁，主线/nixpkgs 内核没有。**
> 模块里 `#ifdef` 会退到 `kretprobes` 方案（`events_source = "kretprobes"`），
> 这是设计好的回退路径，功能可用但机制不同（kretprobe 挂 VFS 函数而非
> fsnotify 广播）。若后续发现漏事件，优先怀疑这里。

### 模块挂载（`deepin-anything.nix`）

- gate：`services.deepin25.deepin-anything.enable`，**默认 false**（不跟随
  `dde-api`）；需要文件搜索的用户显式打开。
- `systemd.packages = [ pkgs.deepin.deepin-anything ]` 带出 logger（system）
  与 daemon（user）两个 unit；daemon 通过
  `systemd.user.services.deepin-anything-daemon.wantedBy = [ "default.target" ]`
  为每个登录用户拉起。
- server unit 在模块里声明，含 `ExecStartPre=modprobe vfs_monitor`、
  `ExecStopPost=rmmod vfs_monitor`、`RuntimeDirectory=deepin-anything`。
- `boot.extraModulePackages` + `boot.kernelModules = [ "vfs_monitor" ]`。
- dconfig（`org.deepin.anything.json`）走 `$out/share/dsg/...`，`deepin.nix`
  已 `pathsToLink` `/share/dsg`，无需额外处理。
