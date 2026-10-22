# cutefish-toolkit 移植

上游：`github.com/cutefishos/cutefish-toolkit`（C++20，Wayland 客户端 + Skia 在
GLES 上自绘）。它是整个移植的 L0：其余 12 个必打仓库都要
`find_package(CutefishToolkit)`。

## 一、Skia：为什么不直接用 nixpkgs 的 skia

`cmake/Skia.cmake` 原本在构建期用 `ExternalProject_Add` 编译一份 pin 死的
Skia（`scripts/fetch-skia.sh`：`chrome/m156`，rev `95ee33d7`）。nix 里网络与
缓存都不允许这么干，先评估了复用 `pkgs.skia`，结论是**不行**：

| 项 | cutefish 需要 | nixpkgs 的 skia | 结论 |
|---|---|---|---|
| 版本 | m156（rev `95ee33d7`，pin 死） | m148（rev `e7c90ecc`） | 跨 8 个 milestone，上游 pin 死说明依赖该版本行为 |
| 库形态 | 静态库（`libskia.a` 等 8 个） | `is_component_build=true` → 共享库 | 缺 modules 的静态库 |
| 后端 | Ganesh GL（`skia_use_gl/egl=true`） | 未开启 GL | `SK_GANESH`/`SK_GL` 后端不在库里 |
| 头文件布局 | `#include "include/core/SkCanvas.h"`（-I 指向源码根） | 装成 `include/skia/...` 且把 `#include "include/` 改写成 `#include "` | 62 个源文件要改，跨版本还会再变 |
| modules | svg / skresources / skparagraph / skshaper / skunicode(_icu/_core) / skcms | 只装 `libskia.so` | 全部缺失 |

所以打一个独立的 `cutefish-skia`，参考 nixpkgs 的 skia 包写法（gn + ninja +
python3，系统库走 `skia_use_system_*`），但换成 cutefish 的 GN 参数。

## 二、cutefish-skia

- `fetchFromGitHub google/skia rev 95ee33d7`（GitHub 是上游 mirror，该 rev 在）。
  hash `sha256-ou4cLjDBhKrL7yUJX/4el/HTDDWcmpL9ZGsdmHjX3I4=`（unpacked NAR）。
  **取这个 hash 要完整下几百 MB，实测 35 分钟**，别随便重新生成。
- GN 参数直接抄 `cmake/Skia.cmake` 里的 `SKIA_ARGS`（否则 `SK_*` defines 与
  编译出来的库对不上，类布局会错），另加 `target_cpu` / `cc` / `cxx` / `ar`
  和 `skia_use_system_*`（freetype、harfbuzz、icu、expat、libpng、jpeg、zlib）。
- 构建目标同上游：`skia modules/svg modules/skresources modules/skparagraph
  modules/skshaper modules/skunicode`。
- 产物：`$out/lib/*.a`，头文件按**源码根布局**放在 `$out/skia/`
  （`include/`、`modules/`、`src/` 下的 `.h`），这样 toolkit 的
  `-I${skia}/skia` 就能照原样 `#include "include/core/SkCanvas.h"`。
- 编译用 clang（上游 `find_program(SKIA_CC clang REQUIRED)`），但产物是静态
  库，与 gcc 编的 toolkit 链接没问题（同为 libstdc++）。

## 三、toolkit 侧：patch 掉内嵌 Skia

`toolkit-use-packaged-skia.patch` 重写 `cmake/Skia.cmake`：去掉
`ExternalProject_Add`、gn/ninja/clang 探测与 `third_party/skia` 检查，改为从
缓存变量 `CUTEFISH_SKIA` 取前缀，`add_library(skia INTERFACE)` 只负责头文件
目录、静态库列表和那一组 `SK_*` defines（defines 必须与 skia 的构建一致）。

包定义通过 `cmakeFlags = [ "-DCUTEFISH_SKIA=${cutefish-skia}" ]` 传值，patch
里不含任何 store 路径。

### FHS 路径：改成读 XDG 环境变量

上游把搜索路径写死成 `/usr/share`、`/usr/local/share`、`/etc/xdg` 和
`/usr/{local/,}{s,}bin`，在 NixOS 上全是空目录。`toolkit-xdg-paths.patch` 改为
按 XDG base directory 规范从环境变量取（环境变量缺失时退回规范默认值）：

| 位置 | 原 | 现 |
|---|---|---|
| `paths.cpp dataDirectories()` | `/usr/local/share` `/usr/share` | `XDG_DATA_DIRS` |
| `paths.cpp configDirectories()` | `/etc/xdg` | `XDG_CONFIG_DIRS` |
| `paths.cpp findExecutable()` | `/usr/local/...` `/usr/...` `/{s,}bin` | `PATH`（`~/.local/bin` 仍优先） |
| `icon_loader.cpp iconBases()` | `/usr/local/share/icons` `/usr/share/icons` | `XDG_DATA_DIRS` 每项 + `/icons` |
| `icon_loader.cpp` pixmaps 回退 | `/usr/share/pixmaps` | `XDG_DATA_DIRS` 每项 + `/pixmaps` |

这几个函数在 NixOS 上全是死的，不只是"路径可疑"：`application_registry`
（应用菜单）、`mime_detection` / `mime_database` / `mime_apps`（MIME 与默认
程序）、`desktop_entry`（`TryExec` 过滤）、图标主题查找都靠它们。

唯一保留的是 `locale.cpp` 的 `/etc/locale.conf`、`/etc/default/locale` ——
读不到只是拿不到 locale，属无害回退。

## 四、构建结果（2026-10-21）

- `cutefish-skia`：gn gen + ninja 919 个目标，约 2.5 分钟。产物 43M：
  `libskia.a`(20M) `libsvg.a`(7.4M) `libskparagraph.a` `libskresources.a`
  `libskshaper.a` `libskunicode_icu.a` `libskunicode_core.a` `libskcms.a`，
  头文件 8 千多个按源码根放在 `$out/skia/{include,modules,src}`。
- `cutefish-toolkit`：54 秒，产出 `libcutefish-toolkit.so.1.0`、
  `libcutefish-toolkit-base.so.1.0`、公共头与 `lib/cmake/CutefishToolkit`。
  patch 与 GN 参数一次通过，没有额外补丁。
- 两个包最后都用包定义里真正的 `fetchFromGitHub` 重跑过一遍（不再靠本地
  `overrideAttrs` 指源码）。产物里残留的 `/usr/share` 只剩 XDG 规范的默认
  回退字符串和注释，不是真实依赖。

### 源码获取（本环境的坑）

google/skia 仓库 1.2G，**GitHub 的 archive tarball 在本环境下载极慢**
（命令行 `curl` / `gh api` 直接 502 或挂起，nix 通道能下但要几十分钟）。
`skia.googlesource.com` 完全不可达（代理 502）。

可行的取源码方式（和上游 `fetch-skia.sh` 一样的思想）：

```bash
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new \
  -o UserKnownHostsFile=$HOME/.ssh/known_hosts -i $HOME/.ssh/id_ed25519"
git init skia && cd skia && git remote add origin git@github.com:google/skia.git
git fetch --filter=blob:none --depth 1 origin 95ee33d7ec7791ab9c071675710a14fe6408ae4f
git sparse-checkout set --cone bin build_overrides experimental/ffmpeg gn \
    include modules src third_party
git checkout --detach FETCH_HEAD   # 98M
```

包定义里仍写 `fetchFromGitHub`（可移植）；本地验证阶段用
`cutefish-skia.overrideAttrs (old: { src = ./cutefish/src/skia; })` 指过去。

## 五、待办

- `src/ui/jxl_library.cpp` 运行期 `dlopen` JPEG XL，CMake 用 `objdump` 读
  SONAME，已加 `binutils`；运行期能否找到库待实机验证。
- 下一步可以开 `cutefish-framework`（同样依赖 toolkit）。
