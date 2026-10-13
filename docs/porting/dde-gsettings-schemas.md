# dde-gsettings-schemas 移植文档

> 角色：**不是上游包**，是本仓库自建的聚合 derivation
> （`runCommand "nixos-gsettings-desktop-schemas"`）。
> 对应 nixpkgs 的 `nixos-gsettings-desktop-schemas` 思路，为 DDE 提供一份
> 编译好的 gsettings override 目录。

## 依赖链

```
glib（getSchemaPath / glib-compile-schemas）
  ← dde-grand-search
  ← startdde
  ← deepin-desktop-schemas
  ← gsettings-desktop-schemas   # dde-appearance 需要 org.gnome.desktop.background
  ← extraGSettingsOverridePackages（NixOS 选项）
```

## 设计要点

- **不使用 `-d` 判断**：`cp -rf "${glib.getSchemaPath pkg}"/*.xml` 对每个列出的包
  都执行；如果某个包没有 `share/gsettings-schemas/<name>/glib-2.0/schemas`，
  构建直接失败。这是**故意的**——静默跳过会让 schema 悄悄消失。
- `NIX_GSETTINGS_OVERRIDES_DIR` 由 `deepin.nix` 的
  `environment.sessionVariables` 指向本包的 schemas 目录。
- `extraGSettingsOverrides` 写成 `nixos-defaults.gschema.override`。
- 可被 NixOS 选项 `services.desktopManager.deepin.extraGSettingsOverridePackages`
  扩展（用于把第三方包的 schema 也纳入）。

## 哪些包**不该**加进来

`dde-session-shell`、`dde-file-manager`、`dde-tray-loader`、
`deepin-system-monitor` **不产出 gschema XML**，这是上游的事实，不是打包 bug：

- dde-session-shell：只有遗留的非 snipe Qt5 构建才装 schema，snipe 分支走 dconfig。
- dde-tray-loader：仓库里两个 `*.gschema.xml` 是 dconfig 迁移后的残留，未被引用。

**不要**为了让构建通过而给这些包加 schema 产出。

## 编译输出（对 NixOS 模块的影响）

| 类型 | 内容 |
|---|---|
| `share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas` | 聚合后的 XML + `gschemas.compiled` + override |
| dbus / systemd / polkit / 用户 | 无 |

唯一消费方是 `deepin.nix` 的 `environment.sessionVariables`。

## 已知遗留

- 上游 nixpkgs issue [#54150](https://github.com/NixOS/nixpkgs/issues/54150)
  若落地可取代这个 hand-rolled derivation。
