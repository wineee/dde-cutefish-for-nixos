# Development Notes

## Current status

This repository syncs DDE packages from nixpkgs at the last revision that still
contained them (`96e751adaf2f` for packages, `15a586f29d59` for NixOS modules),
then progressively upgrades them to Qt6 and maintains only the upgraded set.

Only the packages listed as **maintained** below are built and exposed via
`flake.nix`; everything else in `packages/default.nix` is commented out and will
be re-enabled one by one as it is upgraded.

## Maintained packages

| Package          | Version | Qt   | Notes                                  |
|------------------|---------|------|----------------------------------------|
| dtkcommon        | 6.7.50  | n/a  | provides `DtkBuildHelper.cmake`         |
| dtklog           | 6.7.50  | Qt6  | was `dtk6log`, now `dtklog`            |
| dtkcore          | 6.7.50  | Qt6  | was `dtkcore` (Qt5) + `dtk6core`       |
| dtkgui           | 6.7.50  | Qt6  | was `dtkgui` (Qt5) + `dtk6gui`         |
| dtkwidget        | 6.7.50  | Qt6  | was `dtkwidget` (Qt5) + `dtk6widget`   |
| dtkdeclarative   | 6.7.50  | Qt6  | was `dtkdeclarative` (Qt5) + `dtk6declarative` |
| dtksystemsettings| 6.6.22  | Qt6  | was `dtk6systemsettings`               |
| qt6platform-plugins | 6.0.50 | Qt6 |                                      |
| qt6integration | 6.0.50 | Qt6 | depends on dtkwidget                 |
| treeland-protocols | 0.7.0 | n/a |                                      |
| dde-seatd | 0.9.3-3 | n/a | renamed libseat-compatible seat daemon |
| deepin-pdfium | 1.5.8 | Qt6 | PDFium rendering lib (was Qt5 qmake) |
| docparser | 1.0.26 | n/a | doc content analysis lib (was Qt5) |
| gio-qt | 0.0.16 | Qt6 | was Qt5 (now qt6-only via patch) |
| udisks2-qt6 | 6.0.1 | Qt6 | replaces udisks2-qt5 (deleted) |
| qt6mpris | 1.0.0.1-1deepin2 | Qt6 | was already Qt6; version bump |
| util-dfm | 1.4.5 | Qt6 | dfm6-io/mount/burn/search libs |
| dde-account-faces | 1.0.19 | n/a | data (avatars) |
| deepin-gtk-theme | 25.3.7 | n/a | data (GTK themes) |
| deepin-sound-theme | 15.10.6 | n/a | data (sounds) |
| deepin-wallpapers | 1.7.27 | n/a | data (wallpapers) |
| deepin-icon-theme | 2026.02.27 | n/a | data (icons) |
| deepin-desktop-theme | 1.1.31 | Qt6 | cmake + Dtk6 tools |
| deepin-desktop-base | 2026.09.04 | n/a | moved to core; NixOS-branded |
| deepin-gettext-tools | 1.0.11 | n/a | was already latest; re-enabled |
| deepin-pw-check | 6.0.12 | n/a | full build (Go service + C lib + PAM) |
| dde-api | 6.0.48 | n/a | Go D-Bus service (thumbnails, sound, etc) |
| dde-daemon | 6.1.108 | n/a | Go system/session daemon (16 binaries) |
| deepin-desktop-schemas | 6.0.13 | n/a | Go gschema build tool + schemas |
| startdde | 6.1.6 | n/a | Go session starter |
| dde-application-manager | 1.2.62 | Qt6 | Qt6 (Dtk6 Core + systemd + treeland-protocols) |
| deepin-service-manager | 1.0.24 | Qt6 | Qt6 (Dtk6 Core + libqdbusservice) |
| dde-tray-loader | 2.0.42 | Qt6 | Qt6 (Dtk6 + KF6WindowSystem) |
| dde-shell | 2.0.57 | Qt6 | Qt6 (Dtk6 + WaylandCompositor) |
| dde-file-manager | 6.6.6 | Qt6 | Qt6 (Dtk6 + DDE shell + dfm6); desktop plugin |
| dde-polkit-agent | 6.0.24 | Qt6 | Qt6 (Dtk6 + polkit-qt6 + DDE shell) |
| dde-app-services | 1.0.46 | Qt6 | Qt6 (Dtk6 Core+Gui+Widget + systemd) |
| dde-session-ui | 6.0.50 | Qt6 | Qt6 (Dtk6 Widget + xcb-ewmh) |
| dde-session | 2.0.34 | Qt6 | Qt6 (Dtk6 Tools); kwin_x11 dropped |
| dde-session-shell | 6.0.68 | Qt6 | snipe repo; greeter skipped |
| dde-control-center | 6.1.110 | Qt6 | Qt6 (Dtk6 + DDEShell + polkit-qt6) |
| dde-network-core | 2.0.103 | Qt6 | Qt6 (Dtk6 + KF6NetworkManagerQt) |
| dde-launchpad | 2.0.49 | Qt6 | Qt6 (Dtk6 + DDE shell + appstream-qt) |
| dde-appearance | 1.1.86 | Qt6 | Qt6 (Dtk6 + KF6 + lomiri-qt6.gsettings-qt); X11 fakewm dropped |
| dde-clipboard | 6.1.36 | Qt6 | Qt6 (Dtk6 + DDE shell + tray-loader) |
| dde-grand-search | 6.1.1 | Qt6 | Qt6 (Dtk6 + dfm6-search + qdbus-service) |
| dde-device-formatter | 1.5.11 | Qt6 | was qmake/Qt5; now cmake/Qt6 |
| dde-calendar | 6.6.3 | Qt6 | Qt6 (Dtk6 Core+Gui+Widget + libical) |
| ddm | 0.4.0 | Qt6 | SDDM fork display manager; cmake/Qt6 |
| treeland | 0.11.0 | Qt6 | Wayland compositor (vendored waylib + wlroots) |
| deepin-terminal | 6.5.40 | Qt6 | first app upgraded to Qt6           |
| deepin-calculator | 6.5.40 | Qt6 | upgraded to Qt6 (Dtk6 Widget)       |
| deepin-compressor | 6.5.36 | Qt6 | Qt6 (Dtk6 + KF6); pzip + plugins   |
| deepin-draw | 6.5.43 | Qt6 | Qt6 (Dtk6 Widget)                   |
| deepin-shortcut-viewer | 5.5.6 | Qt6 | Qt6 (Dtk6 Widget); was qmake/Qt5  |
| deepin-editor | 6.7.0 | Qt6 | Qt6 (Dtk6 + KF6 + QtWebEngine)    |
| deepin-music | 7.0.70 | Qt6 | Qt6 (Dtk6 + QtMultimedia + libvlc)   |
| deepin-picker | 6.0.12 | Qt6 | Qt6 (Dtk6 Widget); qmake/xcb        |
| deepin-reader | 6.6.2 | Qt6 | Qt6 (Dtk6 + WebEngine + bundled pdfium) |
| deepin-screensaver | 6.5.11 | Qt6 | Qt6 (Dtk6 Widget+Gui, cmake)       |
| deepin-system-monitor | 6.5.47 | Qt6 | Qt6 (Dtk6 + polkit-qt-1)          |
| deepin-anything   | 7.1.0 | Qt6 | file index/search (daemon+searcher+server); lucene++/boost/spdlog |
| deepin-anything-module | 7.1.0 | n/a | `vfs_monitor.ko` kbuild module (built per running kernel) |

## Upgrade log

- **dtkcommon** `5.7.13` -> `6.7.50`. Installs both `DtkConfig.cmake` and
  `Dtk6Config.cmake` plus `DtkBuildHelper`.
- **dtklog** Qt5 `dtklog` removed; `dtk6log` renamed to `dtklog` and upgraded
  `0.0.2` -> `6.7.50`. Built with `-DDTK5=OFF` to produce
  `libdtk6log.so` + `Dtk6LogConfig.cmake`.
- **dtkcore** Qt5 `dtkcore` (5.6.32) removed; `dtk6core` deleted and `dtkcore`
  upgraded `5.6.32` -> `6.7.50`. Built with `-DDTK5=OFF` to produce
  `libdtk6core.so` + `Dtk6CoreConfig.cmake` / `Dtk6ToolsConfig.cmake`.
- **dtkgui** Qt5 `dtkgui` removed; `dtk6gui` renamed `dtkgui` and upgraded
  `6.0.33` -> `6.7.50`. `-DDTK5=OFF`.
- **dtkwidget** Qt5 `dtkwidget` removed; `dtk6widget` renamed `dtkwidget` and
  upgraded `6.0.33` -> `6.7.50`. `-DDTK5=OFF`.
- **dtkdeclarative** Qt5 `dtkdeclarative` removed; `dtk6declarative` renamed
  `dtkdeclarative` and upgraded `6.0.33` -> `6.7.50`. `-DDTK5=OFF`.
- **dtksystemsettings** `dtk6systemsettings` renamed `dtksystemsettings` and
  upgraded `6.0.2` -> `6.6.22` (repo `dtksystemsettings`). `-DDTK5=OFF`.
- **qt6platform-plugins** `6.0.33` -> `6.0.50`. Built against the qtbase
  private xcb headers (unpacked from `qt6Packages.qtbase.src`).
- **qt6integration** `6.0.33` -> `6.0.50`. Qt 6.9 / missing-include patches are
  upstream in 6.0.50, so no fetchpatch needed.
- **treeland-protocols** `0.4.5` -> `0.7.0`.
- **ddm** `0.3.8` -> `0.4.0`. Display manager for Deepin; cmake/Qt6 build
  unchanged (same CMake flags and FHS-path patches).
- **treeland** `0.10.0` -> `0.11.0`. Wayland compositor (vendored waylib +
  wlroots); rebuilt against treeland-protocols 0.7.0.
- **deepin-terminal** `6.0.17` -> `6.5.40`. First app upgraded to Qt6 (Dtk6
  Widget). Dropped qt5integration/qt5platform-plugins/chrpath deps; added
  qt5compat, libchardet, libuchardet, glib, icu, xorg.xcbutilwm. Patched out two
  hardcoded `/usr/...` install paths.
- **deepin-calculator** `6.5.7` -> `6.5.40`. Upgraded to Qt6 (Dtk6 Widget).
  `find_package(Dtk6 ...)` resolves via the `dtkcommon` `Dtk6Config.cmake`
  forwarder; the `DFrameworkDBus_LIBRARIES` variables are unset in our DTK
  6.7.50 build but upstream no longer uses them. `strictDeps = false` retained
  so `qtsvg` is found (same as the Qt5-era definition).
- **deepin-compressor** `6.0.1` -> `6.5.34`. Upgraded to Qt6 (Dtk6 Widget + KF6
  `kcodecs`/`karchive`). Dropped Qt5 (`libsForQt5.kcodecs`/`karchive`) and
  `udisks2-qt5` (no longer used upstream). Added `qt5compat` (Core5Compat),
  `glib` (gio/gobject via pkg-config), `util-linux` (`mount`). Patched the
  bundled `cmake/translation-generate.cmake` fallback to use the `Qt6::lrelease`
  imported target (was hardcoded `/lib/qt6/bin/lrelease`), stripped `-pie` from
  the global `CMAKE_CXX_FLAGS`, and fixed `/usr` paths in
  `pluginmanager.cpp`/`.desktop`/`.service`/`clipzipplugin.cpp`.
- **deepin-draw** `7.0.2` -> `6.5.43`. Upgraded to Qt6 (Dtk6 Widget). The
  upstream tag scheme reset from `7.0.2` back to `6.5.x` (the 6.5.43 tag is the
  current head). Patched the `com.deepin.Draw.service` `/usr/bin/deepin-draw`
  exec path.
- **deepin-shortcut-viewer** `5.0.9` -> `5.5.6`. Switched from qmake/Qt5 to
  cmake/Qt6 (Dtk6 Core+Widget). Dropped `libsForQt5.qmake`/`qttools`; added
  `qt6Packages.qttools` and cmake. Patched
  `install(TARGETS ... DESTINATION ''${CMAKE_INSTALL_PREFIX}/bin)` (was
  installing into `$out/$out/bin`).
- **deepin-editor** `6.5.15` -> `6.7.0`. Upgraded to Qt6 (Dtk6 Widget + KF6
  `kcodecs`/`syntax-highlighting` + QtWebEngine). Dropped `dde-qt-dbus-factory`
  (dframeworkdbus only referenced in the legacy `.pro`), Qt5 `kcodecs`/
  `syntax-highlighting`. Added `qtwebengine`/`qtwebchannel`/`qt5compat`; set
  `-DBUILD_TESTS=OFF` (tests need Catch2/gtest + daemon-only fixtures). Patched
  the hardcoded `/usr/share/deepin-editor/themes/deepin.theme` default.
- **deepin-music** `7.0.9` -> `7.0.68`. Kept Qt6 (Dtk6 Declarative+Gui+Core +
  QtMultimedia + libvlc + ffmpeg + taglib + SDL2 + ICU). Dropped the bundled
  `fix-library-path.patch` (upstream `DmGlobal::libPath()` now uses
  `QLibraryInfo::path()` with a bare-soname ld.so fallback); switched
  `taglib_1` -> `taglib` (upstream moved to `<taglib/...>` include style),
  `ffmpeg_6` kept for the `libavcodec`/`libavformat` pkg-config; renamed
  `dtk6*` attrs to the de-suffixed `dtk*` set and added explicit `dtkcore`/
  `dtkgui` (pkg-config `dtk6core`/`dtk6gui`) + `icu`.
- **deepin-picker** `6.0.4` -> `6.0.12`. Still qmake but Qt6-aware; renamed
  `dtk6widget` -> `dtkwidget` (+ added `dtkgui` for the `dtk6gui` pkg-config),
  added `xorg.libxcb`/`xorg.xcbutil` (pkg-config `xcb`/`xcb-util`). Patched the
  hardcoded `/usr/lib/qt6/bin/lrelease|lupdate` paths and the
  `com.deepin.Picker.service` exec path.
- **deepin-reader** `6.0.5` -> `6.6.2`. Switched qmake/Qt5 -> cmake/Qt6
  (Dtk6 Widget+Gui+Core, QtWebEngine, QtWebChannel, Core5Compat). Dropped
  `libspectre`/`poppler`/`dde-qt-dbus-factory` (no longer referenced upstream);
  keeps DjVu/libjpeg/libgxps (XPS) + cairo/glib/freetype + cups (batch print
  dlopens libcups). Uses the bundled `3rdparty/deepin-pdfium` snapshot (our
  standalone `deepin-pdfium` 1.5.8 predates the reader-only APIs
  `imageObjectRects`/`fileIdentifier`); force-includes `<cstdint>` for the
  pdfium target (the CMake port drops upstream's global forced-include).
- **deepin-screensaver** `5.0.18` -> `6.5.11`. Switched qmake/Qt5 -> cmake/Qt6
  (Dtk6 Widget+Gui+Core + Qt Quick + Core5Compat). Dropped
  `dde-qt-dbus-factory` (no dframeworkdbus in the cmake tree). Patched the
  `translation-generate.cmake` lrelease fallback, added a missing
  `find_package(... GuiPrivate)`, and fixed `/usr`/`/etc` install + runtime
  paths (`.service`, `dbusscreensaver.cpp`, `utils.cpp`, custom-screensaver
  cmake/desktop). The xscreensaver subdir only regenerates a Debian postinst
  (CRLF, absolute paths), so it is neutralized.
- **deepin-system-monitor** `6.5.4` -> `6.5.47`. Upgraded to Qt6 (Dtk6
  Core+Gui+Widget + polkit-qt-1 via `kdePackages.polkit-qt-1`). Dropped
  `dde-qt-dbus-factory`/`dde-tray-loader`/`gsettings-qt`/`dwayland` (dock
  plugin + Qt5 wayland). The dock plugin and popup subdirs need the
  unpackaged `dde-dock` headers, so they are disabled; builds the main app +
  daemon (service-manager module) + dbus server + polkit system server. Fixed
  `/usr/bin/{kill,renice,pkexec,systemctl}` tool paths, the
  `/usr/lib/deepin-daemon/` install path, and dropped the global `-pie` (breaks
  the daemon MODULE on CMake 4.x).
- **deepin-pdfium** `1.0.2` -> `1.5.8`. Switched from qmake/Qt5 to cmake/Qt6.
  Added zlib/libpng/libjpeg/icu/openjpeg/lcms2/freetype/libchardet; dropped
  Qt5. Fixes `.pc` double-prefix in postInstall.
- **docparser** `1.0.11` -> `1.0.26`. No Qt needed anymore (pure cmake). Added
  freetype, minizip, zlib, file (libmagic); dropped Qt5/qttools. Patched
  `add_link_options(-pie)` (CMake 4.x breaks shared-lib link with `-pie`).
- **gio-qt** `0.0.14` -> `0.0.16`. Upstream builds qt5+qt6 in one run; patch out
  `include(qt5.cmake)`. Library only, so `dontWrapQtApps = true`. Docs disabled
  by default.
- **udisks2-qt6** new package `6.0.1` (cmake/Qt6), replaces `udisks2-qt5`
  (deleted). Fixes `.pc` double-prefix in postInstall.
- **qt6mpris** `1.0.0.1-1deepin1` -> `1.0.0.1-1deepin2`. Version bump only.
- **dde-account-faces** `1.0.16` -> `1.0.19`. Pure data; installPhase copies
  `icons` into `$out/var/lib/AccountsService`.
- **deepin-gtk-theme** `23.11.23` -> `25.3.7`. Pure data; dropped
  `gtk-engine-murrine` (removed from nixpkgs, GTK2-only) and
  `propagatedUserEnvPkgs`. installPhase copies `deepin` + `deepin-dark`.
- **deepin-sound-theme** `15.10.6`. Keep version; `stdenvNoCC`, Makefile-driven.
- **deepin-wallpapers** `1.7.16` -> `1.7.27`. Dropped `dde-api` blur step;
  installPhase copies `deepin/platform/deepin/*` (the `desktop.jpg` lives there)
  and symlinks `default_background.jpg`.
- **deepin-icon-theme** `2024.07.31` -> `2026.02.27`. Manual installPhase
  (7 themes + `gtk-update-icon-cache` guarded by `index.theme`); dropped
  `xorg.xcursorgen`/broken-symlink workaround in favour of
  `dontCheckForBrokenSymlinks`; propagated `papirus-icon-theme` (bloom
  `Inherits=Papirus`).
- **deepin-desktop-theme** `1.0.13` -> `1.1.31`. Now cmake and needs the Dtk6
  tooling (`find_package(Dtk6 COMPONENTS Core Gui Widget)` + Qt6). Depends on
  `dtkcore`/`dtkgui`/`dtkwidget` (which still expose `Dtk6*Config.cmake` in their
  `dev` outputs) and `qt6Packages.qtbase` (6.11 provides `Qt6::GuiPrivate`).
- **deepin-desktop-base** `2024.07.24` -> `2026.09.04`. Moved from
  `packages/misc/` to `packages/core/` (the empty `misc` dir was removed). The
  new Makefile hardcodes `/usr/...` paths under `DESTDIR`, so postInstall
  strips `$out/etc`, python-apt/plymouth/distro-info, and relocates `usr/*`.
  The Makefile no longer installs `distribution.info`/`distribution/*` (only the
  debian `.install` does), so we install them ourselves, rebranded to NixOS.
- **deepin-gettext-tools** keep `1.0.11` (already latest upstream). Re-enabled;
  build-dependency for all Go services and polkit translation.
- **deepin-pw-check** `6.0.2` -> `6.0.12`. Kept the nixpkgs `buildGoModule`
  structure (Go D-Bus service + C library + PAM module + polkit/systemd/dbus
  files) — only bumped version and refreshed `vendorHash`. Dropped the
  `substituteInPlace` on the dbus service file (its `Exec=/bin/false` is
  intentional, no `/usr` path to patch), and the rpm cracklib patch still
  applies cleanly in 6.0.12. 后续修复：systemd unit
  `deepin-passwd-conf.service` 的 `ExecStart=/usr/libexec/deepin-pw-check/...`
  硬编码 → `$out/libexec/...`（Makefile 直接 cp 未做替换）。
- **dde-device-formatter** `0.0.1.16` -> `1.5.11`. Switched from qmake/Qt5 to
  cmake/Qt6 (Dtk6 Widget+Gui). Upstream now uses `qt_add_translations` (no
  more `deepin-gettext-tools` translate scripts). Added `udisks2-qt6` (the
  `udisks2-qt6.pc` satisfies `pkg_check_modules(udisks2-qt6)`). Patched
  `set(QT_COMPONENTS ...)` to add `GuiPrivate` (linked but not declared in
  `find_package`).
- **dde-calendar** `5.14.4` -> `6.6.3`. Switched from qmake/Qt5 to
  cmake/Qt6 (Dtk6 Core+Gui+Widget, Qt SVG/DBus/Sql, bundled
  `3rdparty/kcalendarcore` against `libical`). Dropped
  `dde-qt-dbus-factory`/`sqlite` (QtSql is used for the sqlite backend, no
  raw sqlite headers) and the obsolete `fix-wrapped-name-not-in-whitelist.diff`
  (upstream `clientWhite()` now accepts the 15-char `/proc` truncation of the
  wrapper name). Patched `/bin/bash` in the autostart/systemd `dbus-send`
  commands to `${runtimeShell}`.
- **dde-polkit-agent** `6.0.7` -> `6.0.24`. Switched from qmake/Qt5 to
  cmake/Qt6 (Dtk6 Widget+Core+Tools, polkit-qt6, DDE Shell via
  `find_package(DDEShell)`). Dropped `dde-qt-dbus-factory` (dbus interfaces
  are generated with `qt_add_dbus_adaptor`/`dtk_add_dbus_interface`). The
  binary installs to `lib/polkit-1-dde`, so it is wrapped manually in
  `postFixup`. Patched the `/usr/lib/polkit-1-dde/plugins/` plugin search
  path to `$out`.
- **dde-seatd** new package `0.9.3-3` (meson). A Deepin fork of `seatd` that
  ships a renamed libseat-compatible stack (`libdde-seat.so` + `dde-seatd`
  daemon + `dde-seatd-launch`, socket `/run/dde-seatd.sock`, control socket
  `/run/dde-seatd-control.sock`). Built like nixpkgs `seatd` with
  `-Dlibseat-logind=systemd -Dlibseat-builtin=disabled -Dlibseat-seatd=enabled`.
  Outputs `libdde-seat.pc` and header `dde-seatd/libseat.h` (pkg-config name
  `libdde-seat`, NOT `libseat`).
- **ddm** new package `0.4.0` (cmake/Qt6). A fork of SDDM used as the Deepin
  display manager. Depends on `pam`/`libsystemd`/`systemd`/`xau`/`wayland-client`
  + `treeland-protocols` (generates `treeland-ddm-v1`). Talks to `dde-seatd` via
  raw unix socket (`/run/dde-seatd-control.sock`) — does NOT link libseat. CMake
  fails unless `UID_MIN`/`UID_MAX` are provided (avoids reading `/etc/login.defs`
  in the sandbox); set `UID_MIN=1000`, `UID_MAX=29999`, `DDM_INITIAL_VT=7`.
  Installs `DDMConfig.cmake` + `DDM::Common` (required by treeland). Patched the
  hardcoded `/usr/bin/{X,systemctl}` and session-dir defaults to
  `/run/current-system/sw/...`.
- **treeland** new package `0.11.0` (cmake/Qt6). Wayland compositor based on
  QtQuick + vendored `waylib` + vendored `wlroots` 0.20.2 (both in-tree
  subdirectories; no separate `waylib`/`wlroots` packages). Requires
  `find_package(DDM ... COMPONENTS Common)`, Dtk6 Core/Declarative/SystemSettings,
  and the full wlroots dependency set (wayland-server>=1.26, libdrm, xkbcommon,
  pixman, wayland-protocols>=1.49, libudev, `libseat`>=0.2.0 from upstream `seatd`,
  libdisplay-info, hwdata, libliftoff, libinput, xcb stack, gbm/egl/glesv2,
  vulkan-loader/glslang, lcms2, xwayland, mpv). The vendored wlroots still needs
  the standard `libseat.pc` (provided by `seatd`), while at runtime the compositor
  talks to `dde-seatd` via `SEATD_SOCK=/run/dde-seatd.sock`. Needs
  `wayland-server>=1.26` so must build against the flake-pinned nixpkgs
  (`<nixpkgs>` channel is still on wayland 1.24). Patched the hardcoded
  `/usr/share/wallpapers/deepin/deepin-default.jpg` fallback and the systemd
  unit `/usr/bin`/`/bin` helper paths.
- **dde-api** `6.0.11` -> `6.0.48`. Refreshed `vendorHash`. The old postPatch
  targeted files that no longer exist (`lunar-calendar/huangli.go`,
  `themes/theme.go`, `deepin-login-sound.service`); rebuilt the postPatch
  against the new tree (`adjust-grub-theme/main.go` +
  `language_support/lang_support.go` for `/usr/share/dde-api`, and only
  `misc/scripts/deepin-boot-sound.sh` for `dbus-send`). 后续重构：
  `/usr/lib/deepin-api` 的 `grep -nR` 循环改为明确列出 11 个被 Makefile
  安装的 dbus service + systemd unit，逐个 `substituteInPlace --replace-fail`
  （`debian/dde-api.postinst` 不安装，有意保留）。
- **dde-daemon** `6.0.43` -> `6.1.107`. Dropped the three stale `.diff` patches
  (upstream already fixed wallpaper dir, caller checks, and PATH handling).
  Rebuilt postPatch as broad `find -name '*.go' -exec sed` replacements for
  `/bin/bash`, timezone, xkb, deepin-api/deepin-daemon/dde-control-center
  paths, and `/usr/bin/getconf` (lives in glibc.bin on NixOS). Dropped the
  `dde-session-ui` buildInput/makeBinPath (runtime PATH is provided by the
  NixOS module). Added `env.CGO_CFLAGS = "-std=gnu11"` (go-gir emits old-style
  `()` declarations that clash with GCC 14). Refreshed `vendorHash`.
  `6.1.107` -> `6.1.108`：touchpad 扩展开关 + glib loop 修复，vendorHash 不变。
  后续重构（对齐 f81b263 基准）：新增 `0001-dont-set-PATH.patch` 删两处
  `os.Setenv("PATH")`（原 sed 只删单行，导致 main.go 的 `if err != nil` 检查
  外层残留 err，语义错误），所有 `find -exec sed` 改为逐文件精确替换，并补
  基准也遗漏的 `deepinThemePath`（`/usr/share/deepin-themes/`）与
  `/usr/share/xsessions` 两处。
- **deepin-desktop-schemas** `6.0.7` -> `6.0.13`. Still `buildGoModule` (the
  `override_tool` builds fine in the sandbox — no network needed since it only
  imports go-lib). Refreshed `vendorHash`. 后续重构：`grep -rl "/usr/share"`
  循环（误伤 debian/rpm/archlinux 打包目录）改为明确列出 7 个 `schemas/` +
  `overrides/` 源文件逐个 `substituteInPlace --replace-fail`。
- **startdde** `6.0.15` -> `6.1.6`. Refreshed `vendorHash`; added
  `env.CGO_CFLAGS = "-std=gnu11"` (same go-gir/GCC14 issue). 后续修复：
  `display/color_temp.go` 的 `timeZoneFile=/usr/share/zoneinfo/zone1970.tab`
  → `${tzdata}/share/zoneinfo/zone1970.tab`（新增 tzdata 依赖）。
- **dde-application-manager** `1.2.19` -> `1.2.45`. cmake/Qt6 + systemd +
  treeland-protocols + libxkbcommon. Removes Debian dpkg config in postInstall.
- **deepin-service-manager** `1.0.3` -> `1.0.21`. Rewrote from Qt5 to Qt6
  (Dtk6 Core + Qt6 DBus + libsystemd). Builds `libdeepin-qdbus-service.so` +
  `deepin-qdbus-service.pc`/`-Config.cmake` (satisfies dde-file-manager's
  `find_package(deepin-qdbus-service)`). preConfigure redirects the compile-time
  `SERVICE_CONFIG_DIR`/`SERVICE_LIB_DIR` to `/run/current-system/sw/...`.
- **dde-tray-loader** `1.0.9` -> `2.0.27`. Qt5 -> Qt6 (Dtk6 +
  KF6WindowSystem + wayland). Provides `dde-dock.pc`/`DdeTrayLoaderConfig.cmake`
  for dde-shell and dde-file-manager. 2.0.27 adds the `set_cursor` request to
  `plugin-manager-v1.xml` (required by dde-shell >= 2.0.52).
- **dde-shell** `1.0.10` -> `2.0.52`. Rewrote (Qt6 WaylandCompositor). Dropped
  the obsolete `fix-path-for-nixos.diff`/Qt6.9 fetchpatch chain (2.0.52 is
  built against Qt 6.11 and needs none). 2.0.52 adds
  `frame/wayland/xdgactivation.h` (public header required by dde-launchpad
  2.0.48). postPatch redirects `/etc/` and systemd user unit installs, and
  `/usr/lib/dde-dock` -> `/run/current-system/sw`.
  postInstall overrides the QtWayland.Compositor qmldir (the upstream
  `prefer :/...` directive breaks filesystem plugin resolution). Needs
  `xcb xcb-aux xcb-res xcb-ewmh` (libxcb + xcbutil + xcbutilwm).
- **dde-file-manager** `6.0.57` -> `6.5.121`. Qt5 -> Qt6 (Dtk6 + DDE shell +
  dfm6). Dropped `patch_check_v23_interface.diff` and the stale
  `fix-permission-to-execute` fetchpatch. Stubbed out `libappimage` (not in
  nixpkgs, AppImage thumbnail support). `deepin-qdbus-service` (diskencrypt
  service) comes from `deepin-service-manager`. postInstall rewrites
  `/usr/bin/{dde-file-manager,dde-desktop,...}` in service files and points the
  D-Bus service `Exec` at `deepin-service-manager`'s store path.
- **util-dfm** `1.3.2` -> `1.4.5`. cmake/Qt6 (`OPT_ENABLE_QT6=ON` is default).
  Builds `libdfm6-io`/`-mount`/`-burn`/`-search` + headers/pkgconfig/cmake
  config. Note: our `dtkcore` 6.7.50 dev output ships `Dtk6CoreConfig.cmake`
  (the 6.x cmake package name is `Dtk6Core`, independent of the Nix attr
  `dtkcore`), so `find_package(Dtk6 COMPONENTS Core)` matches directly — no
  `dtk6*`-suffixed alias set is needed. Added `openssl` (1.4.5 links
  `OpenSSL::Crypto` in dfm-burn) and `-DCMAKE_BUILD_TYPE=Release` (avoids the
  default Debug build pulling `BUILD_UNIT_TESTS=ON`).
- **gsettings-qt6 移除独立定义**：原样复用 nixpkgs `lomiri-qt6.gsettings-qt`
  1.1.1（不 fork、不 override）。nixpkgs 版 `.pc` 只支持 `#include <QGSettings>`；
  deepin 下游用 `#include <QGSettings/QGSettings>` 的 dde-appearance 在包内
  postPatch 改为前者。dde-appearance/dde-network-core 直接用
  `lomiri-qt6.gsettings-qt` 作为 buildInput。
- **dde-app-services** `1.0.25` -> `1.0.46`. Qt6 (Dtk6 Core+Gui+Widget +
  systemd). Disables unconditional tests/example subdirs; broad `/usr` sed.
- **dde-session-ui** `6.0.20` -> `6.0.50`. Qt6 (Dtk6 Widget + xcb-ewmh +
  deepin-pw-check + libxrandr). No longer uses gsettings-qt.
- **dde-launchpad** `1.0.8` -> `2.0.48`. Qt6 (Dtk6 + DDE shell +
  appstream-qt + qtwayland). Requires dde-shell >= 2.0.52 (xdgactivation.h).
  postConfigure redirects dde-shell install dirs and qtbase's QML dir; postInstall
  writes on-disk qmldir for its 3 QML modules (embedded in launchpadcommon.so).
  Both postConfigure and postInstall are gone as of 2.0.49 — dde-shell now
  exports relative dirs, the QML is resource-embedded, and the qtbase redirect
  never matched. See "packages/core 补丁规范化（续）".
- **dde-appearance** `1.1.29` -> `1.1.86`. Qt6 (Dtk6 + KF6 + lomiri-qt6.gsettings-qt +
  deepin-service-manager). Replaces `/usr/share/zoneinfo` with `${tzdata}`;
- **dde-clipboard** `6.0.11` -> `6.1.35`. Qt6 (Dtk6 + DDE shell + tray-loader +
  gio-qt6). Hardlinks `-lgtest`; redirects `/etc/xdg/autostart`.
- **dde-grand-search** `5.5.2` -> `6.1.1`. Qt6 (Dtk6 + dfm6-search +
  deepin-qdbus-service + DDE shell). Qt6 auto-detect; forces
  `BUILD_OS_VERSION=25` so the Qt6-only shell plugin builds. postConfigure
  redirects the dde-shell package install dir to `$out` (ds_install_package)
  — removed later, see "packages/core 补丁规范化（续）".
- **dde-session** `1.2.12` -> `2.0.33`. Qt6 (Dtk6 Tools + libcap-ng/libsecret/
  xcb/xcursor/xfixes/x11). Drops the `kwin_x11 --replace` line (and its
  kglobalshortcutsrc pre-step) from `dde-session@x11.service` — treeland is the
  future compositor — and the optional `deepin-keyring-whitebox` branch (not
  packaged). postInstall rewrites the `/usr/bin/{dde-shell,dde-lock,...}`
  references in systemd/D-Bus service files to their store paths. Installs
  `deepin.desktop` xsessions entry, so the NixOS module default session is now
  `deepin` (was `dde-x11`).
- **dde-session-shell** `6.0.68`. Uses the `dde-session-shell-snipe` repo
  (old repo, per user decision). `DDE_SESSION_SHELL_SNIPE=ON` takes the Qt6
  branch. The greeter (`lightdm-deepin-greeter`) needs `liblightdm-qt6-3`
  which nixpkgs doesn't have, so it is skipped via `if(FALSE)` + commented-out
  `pkg_check_modules(Greeter ...)` + removed `''${Greeter_LIBRARIES}` from the
  dde-lock link line; tests are disabled too. `dde-session-shell.conf` is
  redirected from `/var/lib/dde-session-shell/` to `${out}/share/...`.
- **dde-control-center** `6.0.65` -> `6.1.109`. Qt6 (Dtk6 Core+Gui + DDEShell
  + polkit-qt6 + treeland-protocols + wlr-protocols + ffmpegthumbnailer +
  dpkg + icu/openssl). Built with `DISABLE_AUTHENTICATION=ON` (the
  authentication plugin needs `dareader`, not packaged) and
  `ENABLE_WARNINGS_AS_ERRORS=OFF` (Qt 6.11 deprecates
  `QSortFilterProxyModel::invalidateRowsFilter`, which trips `-Werror`).
  Patches `misc/DdeControlCenterConfig.cmake.in` so
  `DDE_CONTROL_CENTER_PLUGIN_INSTALL_DIR` isn't double-prefixed (nixpkgs passes
  `CMAKE_INSTALL_LIBDIR` as an absolute path).
- **dde-network-core** `2.0.34` -> `2.0.102`. Qt6 (Dtk6 Core+Widget +
  KF6NetworkManagerQt + libnm + lomiri-qt6.gsettings-qt + curl). Needs
  dde-control-center (dcc-network plugin), dde-session-shell (dss plugin) and
  dde-tray-loader (provides the `DdeDock` cmake package). Patches
  `dock-network-plugin` to `find_package(... WaylandClientPrivate ...)` (Qt
  6.10+ requires the private target explicitly), installs the dcc-network
  plugin into our own prefix (runtime looks it up via dde-control-center's
  plugin search dir), and stops installing to `/etc/NetworkManager/conf.d`.
  Extra build deps: `wayland-protocols` (FindWaylandProtocols via ECM) and
  `libsysprof-capture` (glib-2.0's `Requires.private` chain).
- **dde-application-manager** `1.2.45` -> `1.2.62`. Routine bump.
- **deepin-service-manager** `1.0.21` -> `1.0.24`. Routine bump.
- **dde-tray-loader** `2.0.27` -> `2.0.42`. Routine bump.
- **dde-shell** `2.0.52` -> `2.0.57`. Upstream moved tray-plugin loading out of
  process into systemd-managed dde-tray-loader services (commit 16d7d64), which
  deleted `panels/dock/loadtrayplugins.{h,cpp}`; the corresponding postPatch sed
  is gone. Restored the `DDE_SHELL_PLUGIN_PATH`/`DDE_SHELL_PACKAGE_PATH`
  qtWrapperArgs (dropped in the previous bump) so third-party shell/tray plugins
  symlinked into `/run/current-system/sw/{lib,share}/dde-shell` are discovered.
  Added a postPatch to strip upstream's new `add_compile_options(-Werror)` — Qt
  6.11 deprecates `QSortFilterProxyModel::invalidateFilter()` which the new
  `panels/dock/tray/ksortfilterproxymodel.cpp` still calls.
- **dde-launchpad** `2.0.48` -> `2.0.49`. Routine bump.
- **dde-clipboard** `6.1.35` -> `6.1.36`. Routine bump.
- **dde-control-center** `6.1.109` -> `6.1.110`. Routine bump.
- **dde-network-core** `2.0.102` -> `2.0.103`. Routine bump.
- **dde-session** `2.0.33` -> `2.0.34`. Routine bump.
- **dde-file-manager** `6.5.121` -> `6.6.6`. New deps: `minizip` and
  `kdePackages.kidletime` (KF6IdleTime) for the textindex service; upstream
  also gained an ocr-extractor plugin requiring the removed
  `linuxdeepin/dtk6ocr`, so that subdirectory is skipped in postPatch. Fixed a
  Qt 6.11 compile error in `encryptutils.cpp` (`ch.unicode()` returns char16_t
  with no matching `QString::arg` overload; cast to uint). Bumped `lucenepp` to
  a post-3.0.9 revision that provides `Lucene::NGramTokenizer` (used by the new
  textindex `profile/` sources).
- **dde-account-faces** `1.0.19`. installPhase now also creates
  `icons/default -> animal/raccoon.png` so AccountsService has a default avatar
  for the greeter (Debian provides it via alternatives).
- **deepin-compressor** `6.5.34` -> `6.5.36`. Routine bump.
- **deepin-music** `7.0.68` -> `7.0.70`. Routine bump.
- **deepin-reader** `6.6.2`. Fixed CMake >= 4 link failure: upstream adds
  `-pie` via `add_compile_options`/`add_link_options`, which breaks the shared
  `libdeepin-pdfium-reader` link (`undefined reference to main`); dropped `-pie`
  in postPatch (nix hardens separately).
- **dde-file-manager** `6.6.6` 后续修复：对比 nixpkgs fork 初版后补齐 12 组
  `--replace-fail`（`/usr/libexec/dde-file-manager`、`/usr/share/{backgrounds,
  wallpapers,deepin}`、`/usr/lib/deepin-daemon`、`/usr/etc/deepin`、
  `/usr/bin/sudo`、`dfm-reencrypt.desktop` 等），`postInstall` 从只处理
  `.service` 扩展到 `.desktop/.policy/.service`（`/usr/bin/false` 占位符单独
  指向 `sw/bin/false`），并补回 Qt5 迁移时丢失的
  `qt6integration`/`qt6platform-plugins`。
- **dde-session** `2.0.34` 后续修复：`sessionmanager.cpp` 的 `/usr/bin/dde-lock`
  （用于校验调用方 cmdline，不改会一律判为非法）、`/usr/libexec/dde-session-ctl`、
  `/usr/bin/dde-am`、`/usr/lib/deepin-daemon/langselector` 等编译进二进制的路径
  补齐；三段 `find … -exec sed` 改为精确 `substituteInPlace`；新增
  `dde-application-manager` 依赖（只为 dde-am 路径，无循环依赖）。
- **dde-session-shell** `6.0.68` 后续修复：`bin/dde-lock` 包装脚本的
  `REAL_BINARY=/usr/libexec/deepin/dde-lock` 是致命路径 —— 不改则锁屏 exec
  一个不存在的文件；`.c`/`.json`/无后缀脚本此前完全没被 blanket sed 覆盖。
  改为按目标分组的精确替换，补 `setxkbmap`/`xdotool`/`systemd-detect-virt`。
- **deepin-service-manager** `1.0.24` 后续修复：`src/CMakeLists.txt` 的两个
  编译期插件搜索目录（`SERVICE_CONFIG_DIR`/`SERVICE_LIB_DIR`）与
  `*.service.in`/日志 JSON 里的 `/usr/bin` 改为精确替换，删掉 `postInstall`
  的 `find $out … -exec sed`。
- **dde-app-services** `1.0.46` 后续修复：`dde-dconfig`/`dde-dconfig-editor` 的
  `setenv("DSG_DATA_DIRS", "/usr/share/dsg:…")` 在 `.cpp` 里（旧代码只 sed 了
  CMakeLists，两个 CLI 工具读不到任何 dconfig 数据）；
  `dde-dconfig-daemon.service` 的 `DSG_DATA_DIRS` 与 `ReadOnlyPaths` 改指
  `/run/current-system/sw/share/dsg`（后者指向不存在的路径会让 systemd 挂载
  命名空间失败）。
- **dde-session-ui** `6.0.50` 后续修复：三段 blanket 替换改为精确替换；补齐
  `/usr/local/share` 下的第二处翻译目录、`dde-blackwidget` 的
  uos_logo/plymouth 路径、`/usr/lib/deepin-daemon/*` 与
  `/usr/bin/{dde-hints-dialog,deepin-login-reminder}`；systemd unit 目录改由
  `-DSYSTEMD_USER_UNIT_DIR` 传入（上游 `pkg_get_variable` 会指回 systemd 的
  store 路径）。
- **dde-appearance** `1.1.86` 后续修复：新增 `no-fakewm.patch` —— 不编译 X11 的
  `dde-fakewm`（本移植只支持 wayland；上游 unit 自己也用 `ExecCondition` 在
  wayland 下跳过它），同时不安装 `com.deepin.wm.service` 与
  `dde-fakewm.service`。`glibc` 只作函数参数（取 `locale.alias` 路径）——
  进 `buildInputs` 会把 glibc 的 include 塞进搜索路径，导致 `stdlib.h` 之类
  解析错乱（fakewm 编译失败正是由此暴露）。
- **dde-clipboard** `6.1.36` 后续修复：托盘插件的翻译路径
  `/usr/share/dde-clipboard/translations` → sw profile。
- **dde-launchpad** `2.0.49` 后续修复：日志配置
  `dist/deepin-log-config/org.deepin.dde.launchpad.json` 里的 `/usr/bin/dde-shell`
  → `${dde-shell}/bin/dde-shell`。
- **NixOS 模块 `pathsToLink`**：删掉 4 个冗余 `/lib/*`（`/lib` 已在 nixpkgs 默认
  列表里且 buildEnv 递归合并子目录 —— 实测 system-path 的 `lib/` 未链接条目为 0，
  这些项从未生效）；补 `/share` 的 `dde-control-center`、`dde-dock`、
  `dde-session-shell`、`dde-session-ui`、`deepin-service-manager`、
  `xsessions`、`wayland-sessions`、`dde-clipboard`、`plugin-dde-appearance`，
  全部从已构建产物的二进制字面量扫出（`QStringLiteral` 存 UTF-16，只扫 ASCII
  会漏）。其中 `xsessions`/`wayland-sessions` 缺失会让 ddm 列不出任何 session。

- **packages/core 补丁规范化（续）**：把剩下的大范围 `find -exec sed` 与
  `grep -rl` 循环改成逐文件 `substituteInPlace --replace-fail`（原则见下方
  「`--replace-fail` 与 `--replace` 的选择」）。逐包：
  - `dde-application-manager` `1.2.62`：删掉整段 `find -name CMakeLists.txt
    -exec sed -i 's|/etc/|$out/etc/|g'` —— 该版本任何 CMakeLists.txt 里都没有
    `/etc`（`git grep <tag> -- '*CMakeLists.txt'` 为空），是死代码；sysconfdir
    只有 `misc/CMakeLists.txt` 的 dpkg hook 用变量拼，由 cmakeFlags 覆盖。
  - `dde-shell` `2.0.57`：同样删掉 `/etc` 那段死代码；`SYSTEMD_USER_UNIT_DIR`
    改走 cmakeFlags 的 `-D`，并删掉同名 env 变量（实测无效，见 Gotchas）。
    `DDEShellConfig.cmake.in` 的三处 `sed -i` 改 `substituteInPlace`，并且**只**
    去掉 `@CMAKE_INSTALL_PREFIX@/` 前缀（保留上游自己算出的相对值），从根上
    修掉「下游把插件装进 dde-shell 只读 store 路径」的问题 —— 见 Gotchas。
  - `dde-calendar` `6.6.3`：`for f in $(grep -rl "/bin/bash" src misc)` 改为
    显式列出 5 个命中文件。
  - `treeland` `0.11.0`：按模式重新分组（pkill / llvm-symbolizer 各 1 个文件、
    systemctl 4 个、`ExecCondition=/bin/sh` 6 个），`--replace` 升级为
    `--replace-fail`。
  - `dde-file-manager` `6.6.6`：`/etc` 只有两处 install 规则（service-group
    drop-in 目录、diskencrypt udev 规则），改精确替换；ocr 插件的删行改成
    `0001-drop-ocr-extractor-plugin.patch`（sed 会静默失效，patch 会响亮失败）；
    `postInstall` 里对安装产物的 find 保留并写明理由。另外删掉紧跟
    `find_package(DDEShell REQUIRED)` 注入 `DDE_SHELL_*_INSTALL_DIR` 的那段
    `sed /a\`：`dependencies.cmake` 那份本来就是死代码（`set()` 写在
    `function()` 里，而该函数从不调用 `ds_*` 宏），`panel-desktop` 那份在
    dde-shell 导出相对目录后已多余；`libappimage` 的两条 `sed -i` 改精确
    `substituteInPlace --replace-fail`。
  - `dde-grand-search` `6.1.1`：同样删掉注入 `DDE_SHELL_*_INSTALL_DIR` 的
    多行替换（`grand-search-shell-plugin` 调 `ds_install_package` +
    `ds_handle_package_translation`，过去确实需要，现在由 dde-shell 的导出
    直接满足）。
  - `dde-session-shell` `6.0.68`：greeter/tests 的 6 步改动（注释 pkg-config
    检查、删 dde-lock 链接行里的 `Greeter_LIBRARIES`、`if(FALSE)` 包住整段
    greeter、注释 `add_subdirectory(tests)` 与 greeter 的 install 规则）改成
    `0001-skip-greeter-and-tests.patch`，postPatch 由 98 行降到 66 行。改为
    patch 的理由：这 6 步里有两步是**插入**行（`sed /i`），读 `substituteInPlace`
    的调用看不出块边界，diff 能。已用「旧 postPatch 双镜像 vs 新 patch」验证
    输出逐字节相同（508 行）。
  - `dde-launchpad` `2.0.49`：`postConfigure` 整段删除。其中重定向 dde-shell
    store 路径的两条 sed 已失效（dde-shell 现在导出相对目录，
    `ds_install_package` 自然落到本包自己的 prefix）；剩下那条重定向 qtbase
    QML 目录的 `find` 实测在 2.0.49 上不命中（QML 已 resource-embed 进
    `launchpadcommon.so`，构建系统里没有任何 QML 安装规则），删掉后重建产物
    文件清单逐条相同。删完 `packages/core` 只剩 `dde-file-manager` 的
    `postInstall` 一处 find 例外。
- **nixos-modules 清理 + dde-daemon 产物路径修复（2026-10-15）**：
  - 删掉 `nixos-modules/deepin/dde-daemon.nix` 的 `services.udev.packages`
    —— 上游 6.1.107 起 Makefile 无 udev 安装规则，产物里也没有 `*.rules`/`udev`
    目录，纯死配置（这条从文档里"待清理"落实了）。
  - 修 `dde-daemon` 6.1.108 的产物路径：Makefile 在 `install:` 里把二进制装进
    `$out/lib/deepin-daemon`（`DAEMON_LIBDIR`）和 `$out/libexec/deepin`，但
    随包 install 的 11 个 session dbus service、5 个 system unit、2 个 user
    unit 的 `ExecStart`/`Exec`，两个 loader wrapper 的 `REAL_BINARY`、
    `lightdm.conf` 的 `session-cleanup-script`、`system_actions.json` 的 3 个
    快捷键 Action 都写死 `/usr/lib(/libexec)/deepin-daemon`。NixOS 无 `/usr`，
    这些单元在真实系统上必然起不来（不是"未知路径"，是"必然失败"）。21 处
    全部改精确 `substituteInPlace --replace-fail`。
    核对方式：`grep -rl "/usr/" <新产物>` 从 57 降到 42，剩下 42 项逐条确认为
    无害（`ReadWritePaths=-/usr/...` 的 `-` 前缀、注释行、`noscheduler` 下永不
    读取的 `scheduler/config.json`、未编进二进制的死代码 `cmdCamera`）。
  - 判"产物里某段路径是不是 bug"的方法：先 `nix build --print-out-paths` 拿到
    store 路径，再 `grep -rl "/usr/" <out>` 全量列出，然后**逐条回到上游源码
    分类**（exec 目标 / 沙箱路径 / 数据 / 死代码）。只按模式批量替换会误伤
    `ReadWritePaths` 和注释。
- **deepin-anything** `6.2.10` -> `7.1.0`（2026-10-15）。Qt5 -> Qt6 重写，同时
  把内核模块拆成独立包并在 NixOS 模块里接上：
  - 上游 7.1.0 原生 Qt6（不再需要移植 patch），架构重构为
    `deepin-anything-daemon`（user）+ `-searcher`/`-server`/`-logger`
    （system）+ `-dispatcher` 四层；新增 `lucenepp`/`boost`/`spdlog` 依赖，
    去掉 dbus。searcher 用 lucene++ 建索引。
  - 上游 6.2.10 本身构建就是坏的：`src/library/CMakeLists.txt` 与
    `src/server/backend/CMakeLists.txt` 调用了从未定义的宏 `install_targets`
    —— 7.1.0 重构后该调用消失，这也是必须升级而不能原地修的原因。
  - 构建期两处：`-DCMAKE_POLICY_VERSION_MINIMUM=3.5`（上游 `cmake_minimum_required`
    写的是 3.1，CMake 4.x 直接拒绝）；`env.NIX_CFLAGS_COMPILE =
    "-Wno-error=deprecated-declarations"`（`pinyin_processor.cpp` 用
    `std::wstring_convert`，libstdc++ 15+ 已 deprecated，项目开 `-Werror`）。
  - `postPatch` 里删掉 `src/CMakeLists.txt` 的
    `add_subdirectory("kernelmod")`：内核模块改由独立包
    `deepin-anything-module` 用 kbuild 直接构建（见下）。
  - `postInstall` 把随包的 unit 里写死的 `/usr/libexec` 改成 `$out/libexec`。
    注意**只有 logger（system）和 daemon（user）两个 unit 需要改** —— 上游
    server unit 的安装被 debhelper 接管、包产物里根本没有它。
  - 内核模块 **`deepin-anything-module`**（新包）：上游 `kernelmod` 走 DKMS
    （只装源码 + dkms.conf），NixOS 下改成独立内核模块包：
    `setSourceRoot = "sourceRoot=$(echo */src/kernelmod)"`，patch 掉 Makefile 里
    写死的 `kdir := /lib/modules/$(shell uname -r)/build` 改用 `$(KERNELDIR)`，
    并补一个上游缺失的 `modules_install` 目标。用
    `linuxPackages.kernelModuleMakeFlags`（含 `KBUILD_OUTPUT=`）+
    `kernel.moduleBuildDependencies`，`hardeningDisable = [ "pic" ]`，
    `installTargets = [ "modules_install" ]`。**模块必须对着它要加载进去的
    那个内核构建**，所以 NixOS 模块里用
    `config.boot.kernelPackages.callPackage` 传入运行内核，
    `boot.extraModulePackages` + `boot.kernelModules = [ "vfs_monitor" ]`。
  - `CONFIG_FSNOTIFY_BROADCAST` 是 UOS 内核补丁，主线/nixpkgs 内核没有 ——
    模块会自动退回 `kretprobes` 方案（上游设计好的回退路径），功能不受影响。
  - NixOS 模块 `nixos-modules/deepin/deepin-anything.nix` 已重写并启用：
    `systemd.packages` + server 服务声明 + user daemon `wantedBy`，
    gate 跟随 `services.deepin25.dde-api.enable`。详见
    `docs/porting/tools.md`。

## Removed (abandoned upstream)

- **dde-widgets** `6.0.23`: Qt5-only and no Qt6 migration upstream. Removed
  with an alias throw, and dropped from the NixOS module (`requiredPackages`,
  `services.dbus.packages`, `systemd.packages`).

- **dde-qt-dbus-factory** `6.0.1`: abandoned upstream (superseded by
  go-dbus-factory / dtkcore DBus). Removed with an alias throw.
- **disomaster** `5.0.8`: abandoned upstream. Removed with an alias throw.
- **dpa-ext-gnomekeyring** `1.0.1`: abandoned upstream. Removed with an alias
  throw, and dropped from the NixOS module (`DDE_POLKIT_AGENT_PLUGINS_DIRS`
  session var and `requiredPackages`).

## Gotchas

### SRI hash for `fetchFromGitHub`

`fetchFromGitHub` fetches `archive/<rev>.tar.gz`, which differs (metadata /
timestamp) from the `refs/tags/<tag>.tar.gz` tarball that `nix-prefetch-url`
or a manual `curl` downloads. A hash computed against the `refs/tags` tarball
will mismatch. Two ways to get the right one:

- Run `nix build` and copy the `got:` hash from the hash-mismatch error, or
- `nix-prefetch-url --unpack https://github.com/<owner>/<repo>/archive/<rev>.tar.gz`
  (returns base32) then convert to SRI:
  `nix hash to-sri --type sha256 <base32>`.

### DTK 6.7.x builds both Qt5 and Qt6 from one source

The `dtk*` repos at 6.7.x default to `DTK5=ON` (Qt5). To build the Qt6 variant
pass `-DDTK5=OFF`. The suffix (`dtk6core` vs `dtkcore`, `Dtk6Log` vs `DtkLog`)
is derived from this flag, not from the repo name.

### Qt 6.9 fixes are already upstream in 6.7.50

The `fetchpatch` Qt 6.9 compatibility patches used by nixpkgs for the 6.0.x
`dtk6*` packages (e.g. `dvtablehook.h`'s `#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)`,
`dconfig2cpp` unicode cast) are already merged into the 6.7.50 tags. Do not
carry them over when upgrading to 6.7.x.

### dtkgui needs dtkcommon's dsg config JSON at configure time

`dtkgui`'s `src/kernel/kernel.cmake` hardcodes
`/usr/share/dsg/configs/org.deepin.dtk.preference.json` on Linux, which only
exists inside the `dtkcommon` store path. Patch it in `postPatch`:

```nix
substituteInPlace src/kernel/kernel.cmake \
  --replace-fail '/usr/share/dsg/configs/org.deepin.dtk.preference.json' \
                 '${dtkcommon}/share/dsg/configs/org.deepin.dtk.preference.json'
```

### `finalAttrs` derivation cannot use bare `src` in postUnpack

In `stdenv.mkDerivation (finalAttrs: { ... })`, the `postUnpack` (and other
phases) must reference the source via `finalAttrs.src.name`, not `${src}`:

```nix
postUnpack = ''
  tar -xf ${qt6Packages.qtbase.src}
  mv qtbase-everywhere-src-${qt6Packages.qtbase.version}/src/plugins/platforms/xcb \
     ${finalAttrs.src.name}/xcb/libqt6xcbqpa-dev/${qt6Packages.qtbase.version}
'';
```

### deepin-terminal 6.5.40 hardcodes `/usr` install paths

`deepin-terminal` installs the manual into
`/usr/share/deepin-manual/manual-assets/application/`, and its vendored
`3rdparty/terminalwidget/CMakeLists.txt` does `set(CMAKE_INSTALL_PREFIX "/usr")`,
which breaks the nix install phase. Patch both in `postPatch`:

```nix
postPatch = ''
  substituteInPlace CMakeLists.txt \
    --replace-fail '/usr/share/deepin-manual/manual-assets/application/' 'share/deepin-manual/manual-assets/application/'
  substituteInPlace 3rdparty/terminalwidget/CMakeLists.txt \
    --replace-fail 'set(CMAKE_INSTALL_PREFIX "/usr")' '# nix: do not override install prefix'
'';
```

Note: `''` cannot be used as an empty `--replace` target in an indented Nix
string (it terminates the string); replace with a comment instead.

### `add_link_options(-pie)` breaks shared libs on CMake 4.x

`docparser` (and other deepin cmake projects) set
`add_link_options(-z noexecstack -pie -fPIC)` globally. On CMake 4.4.x that
`-pie` reaches the shared-library link and fails with
`undefined reference to main`. Strip `-pie` in `postPatch`.

### `.pc` double-prefix (`${prefix}//nix/store/...`)

Deepin cmake libraries generate pkg-config files with
`libdir=${prefix}/@CMAKE_INSTALL_LIBDIR@` while nix already sets absolute
install dirs, producing `${prefix}//nix/store/...`. Fix in `postInstall`:

```nix
postInstall = ''
  find $out/lib/pkgconfig -name "*.pc" -exec sed -i "s|''${prefix}/|/|g" {} +
'';
```

### `dtk*` 6.7.x build docs only for Qt5

The 6.7.x `dtkgui`/`dtkcore` CMake force `BUILD_DOCS=OFF` when Qt6 is selected,
so nothing installs into the `doc` output and nix fails with
`failed to produce output path for output 'doc'`. Drop the `doc` output (or keep
`-DBUILD_DOCS=ON` + `doxygen`) and pass `-DBUILD_DOCS=OFF` to keep the build
clean.

### Path-fix patches changed context in 6.7.x

The nixpkgs `fix-pkgconfig-path.patch` / `fix-pri-path.patch` substitute
`@DTK_VERSION_MAJOR@` in older DTK sources, but 6.7.x uses `@DTK_NAME_SUFFIX@`.
Regenerate the patches against the new source before applying.

### `nixpkgs` input was bumped

Building the Qt6 packages requires a recent nixpkgs (Qt 6.9+ / `wrapGAppsHook3`).
`flake.lock` now pins a much newer nixpkgs than the original snapshot, so the
previously documented "keep nixpkgs untouched" note no longer applies.

### Qt 6.10+ private wayland targets must be `find_package`d explicitly

Qt 6.10 split the private QtWayland targets. Code that links
`Qt6::WaylandClientPrivate` (or `GuiPrivate`, `QuickTemplates2Private`, etc.)
must `find_package(Qt6 COMPONENTS ... WaylandClientPrivate ...)` first — merely
requesting `WaylandClient` is no longer enough. `dde-shell` 2.0.52 does this
correctly in a `if(Qt6_VERSION VERSION_GREATER_EQUAL 6.10)` block; older
consumers like `dde-network-core`'s `dock-network-plugin` don't, and need a
patch. The private targets come from `qtbase`'s cmake dir (not `qtwayland`).

### nixpkgs passes absolute `CMAKE_INSTALL_*DIR`, so templates double-prefix

nixpkgs' cmake wrapper injects absolute `CMAKE_INSTALL_LIBDIR`/
`CMAKE_INSTALL_DATAROOTDIR`. Upstream config-file templates that do
`@CMAKE_INSTALL_PREFIX@/@DCC_PLUGINS_INSTALL_DIR@` end up with the prefix
appended twice (`/nix/store/<pkg>/nix/store/<pkg>/...`). Fix the template to
consume the already-absolute variable (see `dde-control-center`).

### 新增 patch 文件必须先 `git add` 才能构建

flake 的 git fetcher 只把**已跟踪/已暂存**的文件拷进 store；未跟踪的新文件
（例如刚写的 `0001-xxx.patch`）不在其中，构建会报
`getting status of '/nix/store/<hash>-source/.../0001-xxx.patch': No such file
or directory`。加进索引后即可：
`git add packages/<分类>/<pkg>/0001-xxx.patch`。

### 环境变量不会变成 CMake 变量

给派生式写 `FOO = "...";` 只是导出环境变量，CMake 不会把它当成 `${FOO}` 变量；
nixpkgs 的 cmake hook 也只注入 `-DCMAKE_*`，没有通用的 env→`-D` 转发。上游
`if (NOT DEFINED FOO)` 守卫因此照旧走 `pkg_get_variable()` 回退（指回 systemd /
qtbase 的只读 store 路径）。正确写法是放进 `cmakeFlags`：
`"-DFOO=${placeholder "out"}/..."`。`dde-shell` 2.0.57 之前同时留着一个无效的
env 变量 `SYSTEMD_USER_UNIT_DIR` 和一段 sed，两者都已被 `-D` 取代。

### Plugin install dirs pointing at another package's store path

`dde-network-core`'s `dcc-network` plugin installs into
`dde-control-center`'s `plugins_v1.1` dir because `DdeControlCenterConfig.cmake`
exports an absolute `DDE_CONTROL_CENTER_PLUGIN_INSTALL_DIR`. Override it after
`find_package(DdeControlCenter ...)` to install into `$out` (the plugin is
picked up from the control-center plugin search dir at runtime).

### 缩进字符串 `''…''` 里不能写空串 `''`

`postPatch = ''…''` 是 Nix 缩进字符串。串内的 `''` 只有后跟 `'`、`$` 或 `\`
时才是转义，其余情况下被当成字符串结束符，于是下面这行会在第二个 `''` 处
提前收尾，报 `syntax error, expecting ';'`：

```nix
--replace-fail 'libappimage ' ''      # ← 语法错误
```

要传空串就写 `""`。更好的做法是把被删的 token 换成一条自解释的注释
（`# no libappimage in nixpkgs`），生成的构建树里也能看出为什么少了它 ——
注意这条注释要独占一行，`#` 会吞掉本行剩余内容，跟在别的参数后面写会把后面
的参数一起注释掉。

同一原因，替换文本里需要字面 `${…}` 时，缩进字符串写 `''${CMAKE_INSTALL_BINDIR}`，
双引号串写 `"\''${..."`，否则 Nix 先把它当自己的插值插掉。

**多行替换本身没问题**：`dde-grand-search` 就是用多行 `--replace-fail` 往
`find_package(DDEShell REQUIRED)` 后面追加三行 `set(...)`，并且构建通过。
只有**删代码块 / 改逻辑**这种「读 diff 才看得清」的改动才改用 patch 文件
（如 `dde-session-shell` 的 greeter 跳过、`dde-file-manager` 的删 ocr 插件）。

### 下游会写进 dde-shell 只读 store 路径

`dde-shell` 的 `DDEShellConfig.cmake.in` 把安装目录导出成
`@CMAKE_INSTALL_PREFIX@/@DDE_SHELL_*_INSTALL_DIR@`，即写死本包的 store 绝对
路径。下游调 `ds_install_package()` / `ds_handle_package_translation()`
（定义在 `DDEShellPackageMacros.cmake`）时会 `install(... DESTINATION
${DDE_SHELL_*_INSTALL_DIR})`，于是试图往 dde-shell 的只读输出里写。

修法：在 dde-shell 里**只删掉 `@CMAKE_INSTALL_PREFIX@/` 前缀**，别去替换成
`${CMAKE_INSTALL_DATADIR}/dde-shell`。上游自己的值就是相对路径
（`set(DDE_SHELL_PACKAGE_INSTALL_DIR ${CMAKE_INSTALL_DATADIR}/dde-shell CACHE ...)`，
在本包 configure 时已定成 `share/dde-shell`），相对 `DESTINATION` 会自动接上
每个下游自己的 `CMAKE_INSTALL_PREFIX`。而 `${CMAKE_INSTALL_DATADIR}` 只在
「恰好 `include(GNUInstallDirs)` 过」的下游作用域里存在，`@PACKAGE_INIT@`
并不帮你引入它 —— 照抄那个写法会退化成 `set(... /dde-shell)`。

已构建产物可以直接核对：`lib/cmake/DDEShell/DDEShellConfig.cmake` 里的
`set(DDE_SHELL_PACKAGE_INSTALL_DIR …)` 应该是相对的 `share/dde-shell`。
历史上（`64fb51f`，参考三方 flake 那批）用在下游塞覆盖来绕过，
`dde-file-manager` / `dde-grand-search` / `dde-launchpad` 三处覆盖都已删除。

判定下游到底用没用这些变量：在上游 tag 上跑
`git grep -n 'ds_install_package\|ds_build_package\|ds_handle_package_translation'`。
注意 `set()` 写在 `function()` 里只作用于函数作用域（`dde-file-manager` 的
`ddplugin-core/dependencies.cmake` 就是这种死代码），而 `find_package()` 会把
变量留在调用目录的作用域里，函数能读到。

### gsettings override 列表只放真正带 schema 的包

`dde-gsettings-schemas` 的 `gsettingsOverridePackages` 没有 `-d` 存在性判断
（跟 nixpkgs 的 `gnome.nixos-gsettings-overrides` 一致）：包不带
`share/gsettings-schemas/<name>/glib-2.0/schemas` 就会让 `cp` 直接失败，而不是
被静默跳过。所以往列表里加包之前先确认它真的装了 gschema XML。

实测（在已构建的 store 路径上看）：`dde-grand-search`、`startdde`、
`deepin-desktop-schemas`、`gsettings-desktop-schemas` 有；
`dde-session-shell`、`dde-file-manager`、`dde-tray-loader`、
`deepin-system-monitor` 没有，已从列表移除。

这四个都不是我们打包漏了，上游本来就不装（别去"修"它们的 installPhase）：

- `dde-session-shell`：install 规则被 `if (DISABLE_DSS_SNIPE)` 包住
  （`CMakeLists.txt:473`），只有 v20/Qt5 的非 snipe 分支才装
  `xml/com.deepin.dde.session-shell.gschema.xml`。我们
  `DDE_SESSION_SHELL_SNIPE=ON` 走 Qt6 分支，`DISABLE_DSS_SNIPE=FALSE`，
  所以不装 —— 上游有意为之。
- `dde-tray-loader`：`src/loader/configs/` 下那两个 `*.gschema.xml` 在整个
  构建系统里**没有任何引用**，是遗留文件。上游已迁到 dconfig，只装 JSON
  （`dtk_add_config_meta_files`）。
- `dde-file-manager` / `deepin-system-monitor`：源码里根本没有 gschema。

### 升级时不要照抄三方 flake（历史教训）

Qt6 升级早期参考过一个三方 flake（`nixos-unstable-dde-25-flake`，ktechmidas
的 DDE 25 flake，已于 2026-10-15 从 `dde/` 删除），质量不高。它带来的写法
特点：用 `find . -name "*.go" -exec sed -i` 做全局替换替代 nixpkgs 精确的
`substituteInPlace`，并在命令后挂 `|| true` 吞掉失败。

**已经吃过的一次亏**：Qt6 升级那批提交（尤其是 `64fb51f`、`bc8dae9`）参考了它，
结果一批针对具体文件的路径修复被替换掉、没有等价补偿。审计时逐条核对过：

| 项 | 结论 |
| --- | --- |
| `dde-daemon` 的 `/usr/share/wallpapers`、`/usr/share/uadp` | 上游 6.1.x 已改掉，**无需补** |
| `dde-grand-search` 的 `fix-dbus-path-for-daemon.diff` | 上游 6.1.1 的 `.service` 已改成直接 `Exec=dde-grand-search-daemon`，patch 失效，**文件已删** |
| `deepin-reader` 的 `0001-build-tests-with-cpp-14.patch` | `-DBUILD_TESTS=OFF`，tests 不构建，**文件已删** |
| `dde-file-manager` 的 v23 patch + `-DNIX_DEEPIN_VERSION` | 上游 6.5.x 已移除 `DEEPIN_OS_VERSION` 判定，**删除正确** |
| `dde-shell` 的 `DDEShellConfig.cmake.in` | **仍需修，已修到根上**：2.0.57 把本包的 store 绝对路径写给下游，现在只删掉 `@CMAKE_INSTALL_PREFIX@/` 前缀，保留上游自己算出的相对值。下游 `dde-launchpad` / `dde-file-manager` / `dde-grand-search` 那三处"再 sed 一次重定向"都因此多余并已删除，见 Gotchas |
| `dde-calendar` 的 dbus 白名单 | **仍需修**：`CALENDAR_SERVICE_AUTO_EXIT` 在非 Debug 构建下必然定义，而 6.6.3 改成精确相等匹配，NixOS 的 `.dde-calendar-wrapped` 会被拒 |

另外 `dde-daemon` 有两处基线和三方**都没有处理**的真 bug，已补：
`/usr/share/dde-daemon`、`/usr/libexec/dde-daemon`（Makefile 装到 `$out` 下，
Go 代码却写死 `/usr`）。

**判定方法**：别只看当前包定义有没有某行，去
`dde/src-dl/<pkg>-<ver>/` 里看上游对应文件到底长什么样（用
`dde/src-dl/fetch.py <repo> <version>` 下载），再决定要不要补。

### `--replace-fail` 与 `--replace` 的选择

默认一律用 `--replace-fail`：上游改了字符串就应该让构建失败，而不是静默跳过。

多个模式、而每个文件只命中其中一部分时（如 `treeland` 的 systemd unit、
`dde-daemon` 的 9 处 `/usr/lib/deepin-daemon`），**按模式给文件分组**，每组一次
`substituteInPlace`，就仍然能用 `--replace-fail` —— 分组后每个列出的文件必然
含该模式。不要退回 `grep -rl` 循环配 `--replace`。

唯一的例外是 `postInstall` 里对**安装产物**的批量替换（`dde-file-manager`
对 `$out` 下 `*.desktop`/`*.policy`/`*.service`）：文件集由几十条 install 规则
和构建目录共同产生，写死源文件清单会漏掉上游后续新增的文件，静默留下坏路径 —
这里"覆盖面"比"精确性"更重要。这类地方必须在代码里写明理由。

（`dde-launchpad` 的 `postConfigure` 曾对 CMake 生成的 `cmake_install.cmake`
做同类替换，用来把 QML 模块从 qtbase 的只读 `lib/qt-6/qml` 重定向出来。
2026-10-15 实测它在 2.0.49 上根本不命中 —— 删掉后重新构建，产物文件清单逐条
相同（76 个文件）。原因是 QML 模块已经 resource-embed 进 `launchpadcommon.so`，
构建系统里没有任何 QML 安装规则。所以 `packages/core` 现在只剩上面这一处 find。）

**判定"这段 sed 是不是死代码"**：拿包里的 `version` 对应 tag，在
`dde/src/<repo>` 里 `git grep -n <pattern> <tag> -- <pathspec>`。命中为空就是
死代码，直接删（`dde-application-manager` 的 `/etc`、`dde-shell` 的 `/etc` 都是
这么发现的）。
