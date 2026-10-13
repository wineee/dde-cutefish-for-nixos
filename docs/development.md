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
| treeland-protocols | 0.6.0 | n/a |                                      |
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
| dde-daemon | 6.1.107 | n/a | Go system/session daemon (16 binaries) |
| deepin-desktop-schemas | 6.0.13 | n/a | Go gschema build tool + schemas |
| startdde | 6.1.6 | n/a | Go session starter |
| dde-application-manager | 1.2.45 | Qt6 | Qt6 (Dtk6 Core + systemd + treeland-protocols) |
| deepin-service-manager | 1.0.21 | Qt6 | Qt6 (Dtk6 Core + libqdbusservice) |
| dde-tray-loader | 2.0.27 | Qt6 | Qt6 (Dtk6 + KF6WindowSystem) |
| dde-shell | 2.0.52 | Qt6 | Qt6 (Dtk6 + WaylandCompositor) |
| dde-file-manager | 6.5.121 | Qt6 | Qt6 (Dtk6 + DDE shell + dfm6); desktop plugin |
| dde-polkit-agent | 6.0.24 | Qt6 | Qt6 (Dtk6 + polkit-qt6 + DDE shell) |
| dde-app-services | 1.0.46 | Qt6 | Qt6 (Dtk6 Core+Gui+Widget + systemd) |
| dde-session-ui | 6.0.50 | Qt6 | Qt6 (Dtk6 Widget + xcb-ewmh) |
| dde-session | 2.0.33 | Qt6 | Qt6 (Dtk6 Tools); kwin_x11 dropped |
| dde-session-shell | 6.0.68 | Qt6 | snipe repo; greeter skipped |
| dde-control-center | 6.1.109 | Qt6 | Qt6 (Dtk6 + DDEShell + polkit-qt6) |
| dde-network-core | 2.0.102 | Qt6 | Qt6 (Dtk6 + KF6NetworkManagerQt) |
| dde-launchpad | 2.0.48 | Qt6 | Qt6 (Dtk6 + DDE shell + appstream-qt) |
| dde-appearance | 1.1.86 | Qt6 | Qt6 (Dtk6 + KF6 + gsettings-qt6) |
| dde-clipboard | 6.1.35 | Qt6 | Qt6 (Dtk6 + DDE shell + tray-loader) |
| dde-grand-search | 6.1.1 | Qt6 | Qt6 (Dtk6 + dfm6-search + qdbus-service) |
| gsettings-qt6 | 1.1.1 | Qt6 | new; Qt6 build of ubports gsettings-qt |
| dde-device-formatter | 1.5.11 | Qt6 | was qmake/Qt5; now cmake/Qt6 |
| dde-calendar | 6.6.3 | Qt6 | Qt6 (Dtk6 Core+Gui+Widget + libical) |
| ddm | 0.3.8 | Qt6 | SDDM fork display manager; cmake/Qt6 |
| treeland | 0.10.0 | Qt6 | Wayland compositor (vendored waylib + wlroots) |
| deepin-terminal | 6.5.40 | Qt6 | first app upgraded to Qt6           |
| deepin-calculator | 6.5.40 | Qt6 | upgraded to Qt6 (Dtk6 Widget)       |
| deepin-compressor | 6.5.34 | Qt6 | Qt6 (Dtk6 + KF6); pzip + plugins   |
| deepin-draw | 6.5.43 | Qt6 | Qt6 (Dtk6 Widget)                   |
| deepin-shortcut-viewer | 5.5.6 | Qt6 | Qt6 (Dtk6 Widget); was qmake/Qt5  |
| deepin-editor | 6.7.0 | Qt6 | Qt6 (Dtk6 + KF6 + QtWebEngine)    |
| deepin-music | 7.0.68 | Qt6 | Qt6 (Dtk6 + QtMultimedia + libvlc)   |
| deepin-picker | 6.0.12 | Qt6 | Qt6 (Dtk6 Widget); qmake/xcb        |
| deepin-reader | 6.6.2 | Qt6 | Qt6 (Dtk6 + WebEngine + bundled pdfium) |
| deepin-screensaver | 6.5.11 | Qt6 | Qt6 (Dtk6 Widget+Gui, cmake)       |
| deepin-system-monitor | 6.5.47 | Qt6 | Qt6 (Dtk6 + polkit-qt-1)          |

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
- **treeland-protocols** `0.4.5` -> `0.6.0`.
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
  applies cleanly in 6.0.12.
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
- **ddm** new package `0.3.8` (cmake/Qt6). A fork of SDDM used as the Deepin
  display manager. Depends on `pam`/`libsystemd`/`systemd`/`xau`/`wayland-client`
  + `treeland-protocols` (generates `treeland-ddm-v1`). Talks to `dde-seatd` via
  raw unix socket (`/run/dde-seatd-control.sock`) — does NOT link libseat. CMake
  fails unless `UID_MIN`/`UID_MAX` are provided (avoids reading `/etc/login.defs`
  in the sandbox); set `UID_MIN=1000`, `UID_MAX=29999`, `DDM_INITIAL_VT=7`.
  Installs `DDMConfig.cmake` + `DDM::Common` (required by treeland). Patched the
  hardcoded `/usr/bin/{X,systemctl}` and session-dir defaults to
  `/run/current-system/sw/...`.
- **treeland** new package `0.10.0` (cmake/Qt6). Wayland compositor based on
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
  `misc/scripts/deepin-boot-sound.sh` for `dbus-send`).
- **dde-daemon** `6.0.43` -> `6.1.107`. Dropped the three stale `.diff` patches
  (upstream already fixed wallpaper dir, caller checks, and PATH handling).
  Rebuilt postPatch as broad `find -name '*.go' -exec sed` replacements for
  `/bin/bash`, timezone, xkb, deepin-api/deepin-daemon/dde-control-center
  paths, and `/usr/bin/getconf` (lives in glibc.bin on NixOS). Dropped the
  `dde-session-ui` buildInput/makeBinPath (runtime PATH is provided by the
  NixOS module). Added `env.CGO_CFLAGS = "-std=gnu11"` (go-gir emits old-style
  `()` declarations that clash with GCC 14). Refreshed `vendorHash`.
- **deepin-desktop-schemas** `6.0.7` -> `6.0.13`. Still `buildGoModule` (the
  `override_tool` builds fine in the sandbox — no network needed since it only
  imports go-lib). Refreshed `vendorHash`.
- **startdde** `6.0.15` -> `6.1.6`. Refreshed `vendorHash`; added
  `env.CGO_CFLAGS = "-std=gnu11"` (same go-gir/GCC14 issue).
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
- **gsettings-qt6** (new). Qt6 build of ubports `gsettings-qt` 1.1.1 (copied
  from nixpkgs `lomiri/development/gsettings-qt` but pinned to Qt6 via
  `ENABLE_QT6=ON`). Adds the extra `-I@QT_FULL_INCLUDE_DIR@` Cflags so
  `#include <QGSettings/QGSettings>` resolves (nixpkgs' `lomiri-qt6.gsettings-qt`
  only exposes `include/qt6/QGSettings`, breaking that include style). Needed
  by dde-appearance (and later dde-session / dde-session-shell).
- **dde-app-services** `1.0.25` -> `1.0.46`. Qt6 (Dtk6 Core+Gui+Widget +
  systemd). Disables unconditional tests/example subdirs; broad `/usr` sed.
- **dde-session-ui** `6.0.20` -> `6.0.50`. Qt6 (Dtk6 Widget + xcb-ewmh +
  deepin-pw-check + libxrandr). No longer uses gsettings-qt.
- **dde-launchpad** `1.0.8` -> `2.0.48`. Qt6 (Dtk6 + DDE shell +
  appstream-qt + qtwayland). Requires dde-shell >= 2.0.52 (xdgactivation.h).
  postConfigure redirects dde-shell install dirs; postInstall writes on-disk
  qmldir for its 3 QML modules (embedded in launchpadcommon.so).
- **dde-appearance** `1.1.29` -> `1.1.86`. Qt6 (Dtk6 + KF6 + gsettings-qt6 +
  deepin-service-manager). Replaces `/usr/share/zoneinfo` with `${tzdata}`.
- **dde-clipboard** `6.0.11` -> `6.1.35`. Qt6 (Dtk6 + DDE shell + tray-loader +
  gio-qt6). Hardlinks `-lgtest`; redirects `/etc/xdg/autostart`.
- **dde-grand-search** `5.5.2` -> `6.1.1`. Qt6 (Dtk6 + dfm6-search +
  deepin-qdbus-service + DDE shell). Qt6 auto-detect; forces
  `BUILD_OS_VERSION=25` so the Qt6-only shell plugin builds. postConfigure
  redirects the dde-shell package install dir to `$out` (ds_install_package).
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
  KF6NetworkManagerQt + libnm + gsettings-qt6 + curl). Needs
  dde-control-center (dcc-network plugin), dde-session-shell (dss plugin) and
  dde-tray-loader (provides the `DdeDock` cmake package). Patches
  `dock-network-plugin` to `find_package(... WaylandClientPrivate ...)` (Qt
  6.10+ requires the private target explicitly), installs the dcc-network
  plugin into our own prefix (runtime looks it up via dde-control-center's
  plugin search dir), and stops installing to `/etc/NetworkManager/conf.d`.
  Extra build deps: `wayland-protocols` (FindWaylandProtocols via ECM) and
  `libsysprof-capture` (glib-2.0's `Requires.private` chain).

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

### Plugin install dirs pointing at another package's store path

`dde-network-core`'s `dcc-network` plugin installs into
`dde-control-center`'s `plugins_v1.1` dir because `DdeControlCenterConfig.cmake`
exports an absolute `DDE_CONTROL_CENTER_PLUGIN_INSTALL_DIR`. Override it after
`find_package(DdeControlCenter ...)` to install into `$out` (the plugin is
picked up from the control-center plugin search dir at runtime).

### `substituteInPlace` cannot inject `\n` into CMakeLists safely

`substituteInPlace --replace-fail ...` with a `\n` in the replacement produces
unbalanced quoting / parse errors in cmake files. For multi-line edits (or
adding a line after a `find_package`), edit the unpacked source in
`dde/src/` with git and generate a patch file instead.

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
