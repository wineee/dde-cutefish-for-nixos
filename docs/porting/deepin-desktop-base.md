# deepin-desktop-base 移植文档

> 版本：2026.09.04 ｜ 仓库：linuxdeepin/deepin-desktop-base
> 角色：发行版身份信息 + 壁纸/图标/语言数据。`stdenvNoCC`，无编译。

## 依赖链

```
nixos-icons（用于 distribution.info 的 Logo）
```

## 硬编码路径检查

上游 `Makefile` 按 FHS 安装（`PREFIX=/`，`DESTDIR=$(out)`），产物落在
`$out/usr/...`，`postInstall` 把 `$out/usr/*` 上移一层再删 `$out/usr`。

刻意删除的三类内容（NixOS 用不上或依赖 Debian 工具链）：

- `$out/etc` —— `appstore.json`、`lsb-release`、`systemd/{system,logind}.conf.d`
  都是发行版级配置，NixOS 由模块系统管理，不应由包写入。
- `$out/usr/share/python-apt` —— Debian 包管理模板。
- `$out/usr/share/plymouth`、`$out/usr/share/distro-info` —— Plymouth 开机画面
  与 Debian distro 数据。

## 发行版身份（rebrand）

上游 `Makefile` **不安装** `distribution.info`（只有 debian 的 `.install` 装），
包里补上并改成 NixOS：

```
[Distribution]
Name=NixOS
WebsiteName=www.nixos.org
Website=https://www.nixos.org
Logo=<nixos-icons>/share/icons/hicolor/96x96/apps/nix-snowflake.png
LogoLight=<nixos-icons>/share/icons/hicolor/32x32/apps/nix-snowflake.png
LogoTransparent=$out/share/deepin/distribution/distribution_logo_transparent.svg
```

`LogoTransparent` 用包内自带的
`distribution_logo_transparent.svg`（NixOS artwork 许可）。
桌面/锁屏/控制中心「关于」页读这个文件，rebrand 后显示 NixOS。

## 编译输出（对 NixOS 模块的影响）

| 类型 | 内容 |
|---|---|
| `share/backgrounds/deepin/` | 默认壁纸 |
| `share/deepin/` | 发行版信息、版本文件 |
| `share/i18n/` | 语言信息 JSON |
| `share/deepin/distribution/` | 发行版 logo + `distribution.info` |
| gschema / dconfig / dbus / systemd / polkit / 用户 | **全部无** |

本包是纯数据包，对 NixOS 模块没有服务/用户层面的影响。

## 已知遗留

- `share/i18n/i18n_dependent.json` 引用 `/usr/share/locale/locale.alias`，
  属于语言数据描述，NixOS 上 locale.alias 由 glibc 提供，路径不同但未观察到
  实际影响（dde-appearance 才是真正读 locale.alias 的地方，见其移植文档）。
