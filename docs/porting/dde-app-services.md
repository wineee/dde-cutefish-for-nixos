# dde-app-services 移植文档

> 版本：1.0.46 ｜ 仓库：linuxdeepin/dde-app-services ｜ 许可：LGPL-3+
> 角色：DConfig 中心。**DDE 的配置中枢**，其余所有 DDE 包的 dconfig 都靠它。

## 依赖链

```
dtkcore dtkgui dtkwidget dtkcommon → qtbase, qttools
  + glib, systemd
```

产出三个可执行：`dde-dconfig-daemon`（D-Bus 服务）、`dde-dconfig`（CLI）、
`dde-dconfig-editor`（GUI 编辑器）。

## 硬编码路径检查

DSG（Deepin Specification Group）配置数据分散在**几十个包**的
`share/dsg/configs/` 里，靠 `environment.pathsToLink` 汇聚到
`/run/current-system/sw/share/dsg`。dtkcore 也已编译为
`DSG_PREFIX_PATH=/run/current-system/sw`。

| 位置 | 原值 | 处理 |
|---|---|---|
| `dde-dconfig/main.cpp` | `setenv("DSG_DATA_DIRS", "/usr/share/dsg:…")` | → `/run/current-system/sw/share/dsg` |
| `dde-dconfig-editor/main.cpp` | 同上 | 同上 |
| `dde-dconfig-daemon.service` | `Environment=DSG_DATA_DIRS=/usr/share/dsg:…` | 同上 |
| `dde-dconfig-daemon.service` | `ReadOnlyPaths=/usr/share/dsg …` | → `/run/current-system/sw/share/dsg` |
| `dde-dconfig-daemon.service`、`org.desktopspec.ConfigManager.service` | `Exec=/usr/bin/dde-dconfig-daemon` | → `$out/bin/…` |
| `misc/deepin-log-config/*.json` | `"exec": "/usr/bin/dde-dconfig-daemon"` | → `$out/bin/…` |

前两项此前**完全没改**（旧代码只 sed 了 CMakeLists，而 `/usr/share/dsg` 在
`.cpp` 里），导致 `dde-dconfig` / `dde-dconfig-editor` 两个 CLI 工具读不到
任何配置——构建产物里可以扫到残留的 `/usr/share/dsg` 字面量。

`ReadOnlyPaths` 必须指向**真实存在**的路径，否则 systemd 会因挂载命名空间
失败而拒绝启动该 unit。

### 刻意不改

- `/etc/dsg/configs/overrides/...` —— DSG override 的标准位置，NixOS 上的
  gsettings/dconfig override 由 `dde-gsettings-schemas` 与 `deepin.nix` 的
  `NIX_GSETTINGS_OVERRIDES_DIR` 另行处理。
- `/etc/passwd`（`common/helper.hpp`）—— 标准系统文件。
- `tests/` 里的 `/usr/share/dsg` —— 测试代码，未构建。

## 无操作（已删除的死代码）

旧定义在 `postPatch` 里对**所有** `CMakeLists.txt` 做
`sed -i 's|/etc/|…|; s|/usr/share|…|; s|/usr/lib|…|; s|/usr/bin|…|'`
以及 `s|${systemd_USER_UNIT_DIR}|…|`。实际 1.0.46 的 CMakeLists 里
**既没有 `/usr` 也没有 `/etc`，也没有 `systemd_USER_UNIT_DIR` 变量**
（unit 目录由 `cmakeFlags` 的 `-DSYSTEMD_USER_UNIT_DIR=` 提供）。
这两段是纯 no-op，已删除。

## 编译输出（对 NixOS 模块的影响）

| 类型 | 内容 |
|---|---|
| D-Bus **system** service | `org.desktopspec.ConfigManager.service` |
| D-Bus system.d 配置 | 1 |
| systemd system unit | `dde-dconfig-daemon.service` |
| dconfig | 本包是 dconfig 服务的提供方，自身不装 `share/dsg` |
| gschema / polkit / 用户 | 无 |

需要在 `services.dbus.packages` 与 `systemd.packages` 中挂载；`deepin.nix`
已含 `dde-app-services` 相关服务（`services.deepin25.app-services.enable`）。

## 已知遗留

- `dconfig-center/docs/` 与 `example/` 里的 `/usr/share/dsg` 仅为文档/示例。
- 上游 `example` 与 `tests` 目录无条件 `add_subdirectory`，已用
  `substituteInPlace` 注释掉（无 `BUILD_TESTING` 开关可关）。
