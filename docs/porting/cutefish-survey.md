# CutefishOS 移植调研

调研日期：2026-10-21。数据取自 GitHub API（组织 `cutefishos`）与
`cutefishos/packaging` 的 `versions` / `debian/*/control`。

## 当前进度（2026-10-22 更新）

- `.gitignore` 新增 `/cutefish`：上游源码 clone / 快照目录，与 `dde/` 一样不提交。
  源码用 `git clone git@github.com:cutefishos/<repo>`（https 在本环境被代理拒）。
- `packages/cutefish/`，在 `flake.nix` 里以独立属性集接入
  （`packages.<system>.cutefish-*`，另有 `legacyPackages.cutefish`），
  **不并入 DDE 的 `lib.makeScope`**。
- **已构建通过（17/17，全部取自当天 upstream HEAD）**：
  `cutefish-skia`、`cutefish-toolkit`、`cutefish-framework`、
  `cutefish-compositor`、`cutefish-core`、`cutefish-dm`、`cutefish-icons`、
  `cutefish-wallpapers`、`cutefish-qt-plugins`、
  `xdg-desktop-portal-cutefish`，以及应用 `text-editor` / `filemanager` /
  `settings` / `terminal` / `video-player` / `calendar` / `system-monitor`。
- NixOS 模块：`nixosModules.cutefish` → `nixos-modules/cutefish/`
  （`cutefish.nix` 桌面入口 + `dm.nix` 显示管理器 + `artwork.nix` 图标/壁纸），
  见第 5.1 节。已接上 wayland-sessions（`cutefish-core`）、D-Bus 系统服务、
  udev、systemd unit、XDG portal、Qt 插件目录（`QT_PLUGIN_PATH`）、PipeWire，
  以及 `cutefish-dm` 的全套接线（greeter 用户、两个 PAM 栈、
  `display-manager.service` 别名、`/etc/cutefish-dm.conf`、PipeWire 的 user
  drop-in）。详见 `docs/porting/cutefish-core.md` 第四、五节。
- `vm-cutefish` 已换成真会话（cutefish-dm + cutefish-wayland，自动登录
  test/test），镜像构建通过；**真机/VM 里的实际启动还没验过**（需要宿主 GPU
  的 DRM/EGL，沙箱里没有，参考 `../vm` 的做法 `docs/AI-GUIDE.md` §9）。
- 剩余：`cutefish-computer-use`（Rust AI 控制）未打包；`cutefish-installer`
  不打。

**有意留着没改的两处 FHS 路径**（都在 `framework` / `core` 里，理由见
`cutefish-core.md` 第二节）：framework 的 VPN 插件扫描目录
（`/usr/lib/NetworkManager/VPN`，接 `${networkmanager}` 会让每个应用的闭包
多出一个 NetworkManager），以及 cutefish-locales 那套 Debian locale-gen 布局。

> **取 hash 的小技巧**：本环境的 `nix-prefetch-url` 走代理会 502，且
> `git ssh` 对大仓要 `--filter=blob:none`。实测最省事的是
> `curl https://codeload.github.com/cutefishos/<repo>/tar.gz/<rev>`
> （**必须 `env -u https_proxy -u HTTP_PROXY`，直连不走代理**）+ python
> `tarfile` 解压 + `nix hash path --sri --type sha256 <内层目录>`，与
> `fetchFromGitHub` 的 `hash` 完全一致（先在 `cutefish-toolkit` 上对齐过：
> 结果与既有包的 hash 逐字符相同）。

## 一、结论速览

- **24 个公开仓库**，其中真正需要打成 Nix 包的 **18 个**（另 1 个是纯元包
  `cutefish-desktop`），余下 5 个是组织配置 / 打包脚本 / 官网 / 空壳仓库。
- **技术栈已换代**：不再是早期 Cutefish 0.x 的 Qt5 + KF5 路线，而是自研
  toolkit（Wayland 客户端 + **Skia** 在 GLES 上绘制），C++20。Qt 只在可选的
  `qt-plugins`（Qt6 平台主题）里出现。
- **上游不发布 tag**：最新 tag 仍是 `0.8`，而 `packaging/versions` 里全部是
  `1.0`；上游 CI 直接按 `git ls-remote HEAD` 的 commit 构建。Nix 侧必须钉
  commit + 手写 hash，且要自己准备批量更新脚本。
- **最大难点是 Skia**：`cutefish-toolkit` 用 `ExternalProject_Add` 在构建期
  现场编译一份 pin 死的 Skia（`chrome/m156`），需要 `gn` + `ninja` + `clang`，
  并且 gn 只从源码树内部路径查找。这是整个移植里唯一"非标准"的重活。
- **系统集成面比 DDE 小**：没有 dconfig / gsettings 双配置体系，服务是普通
  D-Bus 服务；但要接 PAM、polkit agent、udev、XDG portal、wayland-sessions。
- 粗估：**L0（Skia + toolkit）3–5 人日走通**，L1 框架与合成器 3–5 人日，
  L2 会话/登录 + NixOS 模块 4–6 人日，之后每个小应用 0.5–1 人日。

## 二、仓库总览

| 仓库 | 语言 | ★ | 归类 | 移植 |
|---|---|---|---|---|
| cutefish-toolkit | C++ | 225 | L0 自研 UI 工具包（内嵌 Skia） | 必须，最先 |
| cutefish-framework | C++ | 23 | L1 系统能力客户端（声音/网络/蓝牙/电源） | 必须 |
| cutefish-compositor | C++ | 103 | L1 Wayland 合成器 + shell（dock/通知/控制中心） | 必须 |
| cutefish-dm | C++ | 53 | L2 显示管理器（PAM + greeter + session） | 必须 |
| cutefish-core | C++ | 278 | L2 会话、系统服务、polkit agent、录屏 | 必须 |
| filemanager | C++ | 122 | L3 应用 | 是 |
| settings | C++ | 63 | L3 应用 | 是 |
| terminal | C++ | 52 | L3 应用（GPL-3.0） | 是 |
| text-editor | C++ | 16 | L3 应用 | 是 |
| video-player | C++ | 7 | L3 应用 | 是 |
| calendar | C++ | 0 | L3 应用 | 是 |
| system-monitor | C++ | 0 | L3 应用 | 是 |
| xdg-desktop-portal-cutefish | C++ | 0 | L3 门户后端 | 必须（桌面功能完整性） |
| cutefish-computer-use | Rust | 0 | L3 AI 电脑控制（wayland + 截图编码） | 可选 |
| cutefish-installer | C++ | 0 | 安装器（分区/daemon/polkit） | 否（NixOS 不需要） |
| qt-plugins | C++ | 14 | Qt6 平台主题/图片格式/滚动（Qt6） | 可选 |
| icons | CMake | 40 | 图标主题（GPL-3.0） | 是 |
| wallpapers | CMake | 58 | 壁纸（许可标注 NOASSERTION，需人工确认） | 是 |
| calculator | C++ | 12 | **已 archived**，Qt5 旧代码，不在构建清单 | 否 |
| cutefish-desktop | — | — | 纯元包（仅存在于 packaging 的依赖集合） | 否（用 NixOS 模块代替） |
| packaging | Shell | 0 | Debian 打包 + CI | 否（但 `debian/control` 是依赖权威来源） |
| .github | Shell | 0 | 组织配置 + CI | 否 |
| website | Astro | 0 | 官网 | 否 |
| getting-started | — | 18 | 只有 README/LICENSE | 否 |
| plymouth-theme | — | 3 | 2021 年后停更 | 否 |

组织描述已改为 "A beautiful, agentic Linux distribution, formerly CutefishOS"，
日更活跃（本次调研当天仍有提交），方向明显转向 AI agent 桌面
（`cutefish-computer-use`、compositor 的 `cutefish-computer-control-v1` 协议、
core 里的"记住允许的 agent 应用"）。

## 三、依赖分层

```
cutefish-toolkit  ──►  Skia(pinned, 源码编译) + wayland-client + EGL/GLES
       ▲                  + fontconfig/freetype/harfbuzz/icu + png/jpeg/webp/tiff/heif/jxl
       │
cutefish-framework ──► pipewire, systemd, icu, png  （clients: 音频/网络/蓝牙/电源）
       ▲
    ┌──┴───────────────┬─────────────────┐
cutefish-compositor  cutefish-core     cutefish-dm
 (wayland/seat/drm/  (session, services,(pam, systemd,
  gbm/input/udev/     polkit-agent,      dbus policy)
  xcb/xwayland/pw)    ffmpeg/va/vaapi)
       ▲
    应用：filemanager / settings / terminal / text-editor / video-player
          calendar / system-monitor / xdg-desktop-portal-cutefish
       ▲
    artwork：icons / wallpapers；可选：qt-plugins(Qt6) / computer-use(Rust)
```

**强耦合警告**：toolkit 与 compositor 之间跑自研 wayland 协议
（`cutefish-shell-v1`、`cutefish-surface-blur-v1`、`cutefish-window-hints-v1`、
`cutefish-computer-control-v1`），两侧必须同版本构建。overlay 里要一次性
升级这一组，不能各自追 HEAD。

## 四、外部依赖 → nixpkgs

| 上游依赖 | nixpkgs | 备注 |
|---|---|---|
| wayland / wayland-protocols **>= 1.39** | `wayland` `wayland-protocols` | 版本要求较新，需确认当前 nixpkgs rev 达标 |
| egl / glesv2 / libdrm / libgbm | `libglvnd` `mesa` | |
| libseat / libinput / libudev | `seatd` `libinput` `systemd` | |
| xkbcommon / xcb* / Xwayland | `libxkbcommon` `xorg.libxcb*` `xwayland` | compositor 内置 xwayland 支持 |
| pipewire >= 0.3 | `pipewire` | 录屏 + greeter 静音 drop-in |
| ffmpeg (avcodec/avformat/avutil/swscale) + libva | `ffmpeg` `libva` | 仅 core 录屏 |
| fontconfig / freetype2 / harfbuzz / icu | 同名 | |
| png/jpeg/webp/tiff/heif/**jxl** | 同名 | jxl 是运行时 `dlopen`，CMake 会 objdump 校验 SONAME |
| libsystemd / PAM / polkit | `systemd` `pam` `polkit` | |
| clang + gn + ninja | `clang` `gn` `ninja` | **仅 Skia 构建需要，gn 在 nixpkgs 有** |
| GoogleTest（仅测试） | `gtest` | 全部仓库默认 `BUILD_TESTING=OFF` |

运行期依赖服务（NixOS 模块里要开）：`accountsservice`、`polkit`、
`gsettings-desktop-schemas`、`power-profiles-daemon`、`udisks2`、`fuse3`、
`NetworkManager`、`bluez`、`gnome-keyring`、`upower`、`pipewire + wireplumber`。

## 五、NixOS 模块要接的系统集成点

| 类型 | 出处 | NixOS 侧做法 |
|---|---|---|
| systemd system unit | `cutefish-dm/data/cutefish-dm.service`（装到 `/usr/lib/systemd/system`） | `systemd.services.cutefish-dm` 或 `systemd.packages` |
| systemd user drop-in | dm 给 `pipewire*.{service,socket}`、`wireplumber.service` 写 `no-greeter-audio.conf`；core 给 `xdg-document-portal.service.d` 写 `document-portal-stop.conf` | drop-in 目录要改成 `$out` 下，并在模块里 `systemd.user.services.<x>.path` 或直接用 `environment.etc` |
| PAM | `cutefish-dm.pam`、`cutefish-dm-greeter.pam`（装到 `/etc/pam.d`） | `security.pam.services.cutefish-dm{,-greeter}` |
| D-Bus system policy | `org.cutefish.DisplayManager.conf`、`org.cutefish.Locales.conf`、`org.cutefish.Installer.conf` | `services.dbus.packages` |
| D-Bus 服务 | core 下 `org.cutefish.{Appearance,Battery,Power,Locales,Privacy,Language,NightLight,Services.Brightness}` + `AppRuntime` 的 `*.service.in` | 同上，`services.dbus.packages` |
| polkit | core 自带 **polkit-agent**（`polkit-agent/`），installer 带 `.policy` | `security.polkit.enable` + 把 agent 挂进会话自启动；polkit 规则文件随包 |
| udev rules | `60-cutefish-ddc.rules`、`60-cutefish-privacy.rules` | `services.udev.packages` |
| wayland-sessions | `core/session/cutefish-wayland.desktop` + `cutefish-wayland-session` 脚本 | 装进 `share/wayland-sessions`，配合 dm 或 `displayManager.sessionPackages` |
| 用户/组 | Debian `postinst` 里 `adduser` | `users.users.<cutefish>`（需确认名字，见待验证） |
| XDG portal | `xdg-desktop-portal-cutefish` | `xdg.portal.extraPortals` + `xdg.portal.config` |
| fontconfig | `cutefish-services/appearance/fontconfig.conf`（模板 `.in`） | 作为配置文件随包，运行期生成用户配置 |
| 录屏/截图权限 | pipewire + `cutefish-computer-control-v1` 协议 | 走 portal；agent 授权目前是 core 里的自研 prompt |

### 5.1 已落地的模块（2026-10-21）

`flake.nix` 暴露 `nixosModules.cutefish`，它注入自己的 overlay
（`pkgs.cutefish = import ./packages/cutefish { pkgs = final; }`），与
`pkgs.deepin` 互不干扰：

```nix
services.desktopManager.cutefish.enable = true;   # 拉起 artwork + 桌面基础
services.cutefish.artwork.enable = true;          # 只想用图标/壁纸时可单独开
services.cutefish.artwork.wallpapers.enable = false;  # 壁纸是 unfree，可关
```

- `artwork.nix`：`cutefish-icons` 进 `systemPackages`（靠 `xdg.icons` 被找到），
  壁纸另需 `environment.pathsToLink = [ "/share/backgrounds" "/share/wallpapers" ]`。
- **`cutefish-wallpapers` 是 `unfreeRedistributable`**（Unsplash License），
  默认装，所以整机会要求 `nixpkgs.config.allowUnfree = true`（或
  `allowUnfreePredicate`）；关掉上面那个开关即可免此要求。
- `cutefish.nix` 目前只做 `hardware.graphics` / polkit / fonts / xdg 基础，
  **会话、PAM、D-Bus、udev、portal 要等 compositor 与 dm 打包后再接**，
  代码里留了 TODO 注释指明顺序。

模块求值验证方式（新文件必须先 `git add`，否则 `git+file://` 取不到）：

```bash
nix eval --impure --expr '
let flake = builtins.getFlake "git+file:///home/ut004971@uos/dde-nixos";
in (flake.inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [ flake.nixosModules.cutefish ({ ... }: {
    boot.loader.grub.enable = false;
    fileSystems."/" = { device = "/dev/sda"; fsType = "ext4"; };
    system.stateVersion = "26.05";
    services.desktopManager.cutefish.enable = true;
  }) ];
}).config.environment.systemPackages'
```

### VM

`vm-cutefish/` 是照 `vm/` 抄的独立 flake（`dde-nixos.nixosModules.cutefish` +
`qemu-vm.nix`，8 核 / 8G / 16G 盘，2223 端口转发 ssh，virtio-vga-gl）。

```bash
cd vm-cutefish
nix build --no-write-lock-file --impure   # 或只 eval toplevel.drvPath
./result/bin/run-nixos-vm
```

起的就是真会话：`cutefish-dm` 占 tty1，`cutefish-wayland`（core 监督
compositor）在 tty2，开自动登录 `test`/`test` 跳过登录界面（第二个 compositor，
VM 里没必要再起一个）。注意 vm 里开了 `nixpkgs.config.allowUnfree = true`
（壁纸）。

调试入口：ssh 2223 进去看 `journalctl -u cutefish-dm`、`-u display-manager`，
会话自己的日志在 `~/.local/state/cutefish*`（toolkit 的日志分类）。会话起不来
时 tty2+ 的 getty 还能登（unit 里 `Conflicts=getty@tty1.service`，只让出 tty1）。

## 六、移植难点（按风险排序）

### 1. Skia 内嵌构建（最高风险）

`toolkit/scripts/fetch-skia.sh` + `toolkit/cmake/Skia.cmake`：

- 固定 `SKIA_REVISION=95ee33d7ec7791ab9c071675710a14fe6408ae4f`
  （分支 `chrome/m156`，2026-09-29 的提交）。
- 用 `git clone --filter=blob:none --depth 1` + `sparse-checkout set --cone
  bin build_overrides experimental/ffmpeg gn include modules src third_party`
  取部分源码，然后 `python3 bin/fetch-gn` 从网络拉 gn 二进制。
- CMake 侧 `ExternalProject_Add(skia-build)`：`gn gen` → `ninja -C <dir>
  skia modules/svg modules/skresources modules/skparagraph modules/skshaper
  modules/skunicode` → 产出 8 个静态库
  （`svg skresources skparagraph skshaper skunicode_icu skunicode_core skia skcms`）。
- 三个必须绕过的点：
  1. `find_program(SKIA_GN gn PATHS ${SKIA_SOURCE_DIR}/bin NO_DEFAULT_PATH REQUIRED)`
     —— **只认源码树里的 gn**，nixpkgs 的 gn 要在解包后软链进去
     （`ln -s ${gn}/bin/gn third_party/skia/bin/gn`），否则 patch 掉 `NO_DEFAULT_PATH`。
  2. `find_program(SKIA_CC clang REQUIRED)` —— 必须给 `clang`，gcc 未经上游验证。
  3. 构建期无网络，`fetch-skia.sh` 不能跑，源码要预取。

建议做法：

```nix
# 1) 固定输出 derivation 预取 Skia 源码（github.com/google/skia 镜像含该 rev）
skiaSrc = fetchFromGitHub {
  owner = "google"; repo = "skia";
  rev = "95ee33d7ec7791ab9c071675710a14fe6408ae4f";
  hash = "sha256-...";   # 仓库约 1.2 GB，tarball 较大，只取一次
};

# 2) 把 Skia 单独打成 derivation，toolkit 通过 args.gn 复用，避免每次重编
```

**强烈建议先给上游提 issue/PR**：让 `Skia.cmake` 支持"外部已构建好的 Skia"
（`SKIA_BUILD_DIR` / `SKIA_LIB_DIR` 可传入、跳过 `ExternalProject`）。否则
toolkit 每次改动都会触发 Skia 全量重编（几十分钟），且无法被 Nix 缓存复用。

### 2. 上游无 tag，18 个包要钉 commit

无语义化版本可跟。做法：写一个脚本按 `packaging/versions` 的顺序批量
`git ls-remote` 取 HEAD → 更新 `rev`/`hash`（类似本仓库 `dde/src-dl/fetch.py`
的思路）。注意 compositor/toolkit/core 必须**同日** commit，避免协议错配。

### 3. 硬编码 FHS 路径

按文件数粗查（GitHub 代码搜索）：core 16 个文件、compositor 17 个、dm 5 个、
framework 2 个含 `/usr/`。类型集中且可预期：

- `/usr/lib/systemd/system`、`/usr/lib/systemd/user/*.d`（**已知具体 install 目标**）
- `/etc/pam.d`（`CMAKE_INSTALL_FULL_SYSCONFDIR`）
- `/usr/share/...` 数据（光标主题、xsessions、壁纸、字体配置）
- 少量可执行文件探测（`/usr/bin/...`）

处理原则沿用本仓库四步法：**逐条回上游源码分类**，只 patch 真正会失败的
（systemd unit 目标、pam.d、dbus service exec），不要按模式批量 sed ——
`ReadWritePaths=-/usr/...`、注释、死代码都会误伤。

### 4. D-Bus / polkit / PAM 的"运行期正确性"

Cutefish 自己实现了 polkit agent 和一批系统服务，这一块在 NixOS 上不像 DDE
那样有 dconfig 之类的历史包袱，反而好接；但 greeter 静音、document-portal
停用这类 **drop-in** 要确保装到 `$out/lib/systemd/user/...` 并被加载。

### 5. 可选件的取舍

`cutefish-computer-use` 是 Rust，仓库里 **没有提交 `Cargo.lock`**（只有
`Cargo.toml`，`publish = false`），`buildRustPackage` 需要先生成 lock 或用
`cargoHash`；且它依赖自研 wayland 协议，必须与 compositor 同版本。建议放到
主线跑通后再做。

## 七、建议实施路线

| 阶段 | 内容 | 产出 |
|---|---|---|
| P0 | `cutefish-skia`（独立 derivation，预取源码 + gn/ninja/clang） | 一个能编出 8 个静态包的包 |
| P1 | `cutefish-toolkit`（改 `Skia.cmake` 复用 P0；导出 `CutefishToolkitConfig.cmake`） | `nix build .#cutefish-toolkit` 通过 |
| P2 | `cutefish-framework` → `cutefish-core` → `cutefish-compositor` | 三个包通过，协议版本对齐 |
| P3 | `cutefish-dm` + `nixos-modules/cutefish/`（PAM、dbus、udev、user、wayland-sessions） | VM 能进登录界面 |
| P4 | 应用与 artwork（filemanager/settings/terminal/…/icons/wallpapers/portal） | 桌面可用 |
| P5（可选） | `qt-plugins`、`cutefish-computer-use` | Qt 应用观感、AI 能力 |

每个阶段结束跑 `nix build .#<pkg> --print-out-paths --no-link` 验证，按本仓库
惯例同步更新 `docs/development.md`。

## 八、本环境取 hash / 取源码的做法

- **`nix build` 能下载 github.com 的 archive tarball**，但命令行
  `curl` / `git clone https` / `nix-prefetch-url` 会被代理拒（CONNECT 502）。
  所以取 hash 最省事的办法是：先随便填一个 hash 跑 `nix build`，从
  `got: sha256-...` 里取真值。
- 离线预估 hash（gh api tarball → python tarfile 解压 → `nix hash path`）对
  普通仓库准确（wallpapers 一次命中），但对 `icons` 这种两万多文件、大量
  悬空符号链接的仓库会偏 —— 仍以 nix 报的 `got:` 为准。
- 看源码用 ssh：`GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new
  -o UserKnownHostsFile=$HOME/.ssh/known_hosts -i $HOME/.ssh/id_ed25519"
  git clone --filter=blob:none --depth 1 git@github.com:cutefishos/<repo>`。
  （root 环境下 ssh 默认去找 /root/.ssh，必须显式指定。）

## 九、待验证 / 风险

- ~~当前 nixpkgs（flake.lock `6510408d`）的 `wayland-protocols` 是否 >= 1.39、
  `gn` 是否可用~~ **已确认（2026-10-21）**：`wayland-protocols` 1.49、
  `gn` 0-unstable-2026-08-14 都在；另有 ninja 1.13.2 / clang 21.1.8 /
  libjxl 0.12.0 / pipewire 1.6.9 / seatd 0.9.3。Skia 那关没有缺件。
- `icons` 是 GPL-3.0、`wallpapers` 许可 NOASSERTION：写 `meta.license` 前需
  人工确认实际 LICENSE 文本。
- `cutefish-dm` 的 Debian `postinst` 建的账号名与用途未细查，模块写
  `users.users` 前要读一遍。
- `cutefish-toolkit` 的 jxl 是运行期 `dlopen`，CMake 会 `objdump` 校验 SONAME，
  Nix 下路径要确保能被找到（可能需要 wrap `LD_LIBRARY_PATH`）。
- 上游日更且方向在变（AI agent），移植时建议先冻结一组 commit 再推进。
