# deepin-service-manager 移植文档

> 版本：1.0.24 ｜ 仓库：linuxdeepin/deepin-service-manager ｜ 许可：LGPL-3+

## 依赖链

```
dtkcore → qtbase → systemd
```

无 DTK GUI 依赖。同时产出：
- `libdeepin-service-framework.so`（插件框架，供 dde-daemon / dde-appearance /
  dde-file-manager 等复用）
- `deepin-service-manager` 可执行程序
- `libqdbusservice` 静态/动态库 + `deepin-*-service.pc` + CMake config

## 硬编码路径检查

源码（`.cpp`/`.h`/`CMakeLists.txt`）**没有任何 `/usr` 路径**。所有 `/usr` 只出现在
三处：

| 位置 | 原值 | 处理 |
|---|---|---|
| `src/CMakeLists.txt` | `${CMAKE_INSTALL_PREFIX}/share/deepin-service-manager/` | → `/run/current-system/sw/share/deepin-service-manager/` |
| `src/CMakeLists.txt` | `${CMAKE_INSTALL_FULL_LIBDIR}/deepin-service-manager/` | → `/run/current-system/sw/lib/deepin-service-manager/` |
| `misc/*.service.in` ×3 | `ExecStart=/usr/bin/deepin-service-manager` | → `$out/bin/…` |
| `misc/deepin-log-config/*.json` | `"exec": "/usr/bin/deepin-service-manager"` | → `$out/bin/…` |

前两项不能指向 `$out`：插件 JSON 与 `.so` 由**其他包**（dde-appearance、
dde-file-manager、dde-network-core 等）安装，靠 `environment.pathsToLink`
的 `/lib`（nixpkgs 默认，自动合并子目录）与 `/share/deepin-service-manager`
汇聚到 `/run/current-system/sw`。指向 `$out` 会找不到任何插件。

第三项改 `$out` 是对的——unit 里的 ExecStart 是本包自己的二进制。

`misc/deepin-log-config/*.json` 属于 deepin-log-viewer 的日志配置，只影响
日志查看器能否定位可执行文件，顺手一并修正。

**未改**：`debian/`、`develop-guide.md`、`src/demo/` 里的 `/usr` —— 分别是
Debian 打包元数据、文档示例和 demo（未构建）。

## 编译输出（对 NixOS 模块的影响）

| 输出类型 | 位置 | 说明 |
|---|---|---|
| systemd system unit | `lib/systemd/system/` ×5 | `deepin-service-manager.service`、`deepin-service-plugin@.service`、`deepin-service-group@.service`、`…-group@deepin-daemon.service.d/override.conf`、`multi-user.target.wants/` |
| systemd user unit | `share/systemd/user/` ×4 | 含 `dde-session-initialized.target.wants/` |
| D-Bus 系统总线配置 | `share/dbus-1/system.d/org.deepin.ServiceManager1.conf` | 需 `services.dbus.packages` |
| dconfig | 无 | 本包不装 `share/dsg` |
| gschema | 无 | — |
| polkit | 无 | — |
| 用户/组 | 无 | — |

`.wants/` 里是**文件副本**（不是指向 store 的符号链接），且 NixOS 不处理
`[Install]` 段，因此不会自动启用；需要显式
`systemd.packages`（`deepin.nix` 已包含）。
`deepin-service-manager.service` 的 `ExecStart` 已指向 store 绝对路径，
不依赖 NixOS 注入的默认 PATH。

## 已知遗留

- `override.conf` 里没有 `/usr` 路径，无需处理。
- demo 插件（`src/demo/*`）未构建；`org.deepin.service.sdk.demo.service` 里的
  `/usr/bin/qdbus-service-demo` 不会进入产物。
