{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6Packages,
  dtkcore,
  dtkwidget,
  dtkcommon,
  deepin-gettext-tools,
  glib,
  xcbutilwm,
  libxrandr,
  systemd,
  gtest,
  deepin-pw-check,
  libxcrypt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-session-ui";
  version = "6.0.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-session-ui";
    rev = finalAttrs.version;
    hash = "sha256-+1dOzyTrxkKAmRoFhVjz8lVJQfN+8BM0oKwsYa8uLFs=";
  };

  postPatch = ''
    # Translations are aggregated into the system profile by pathsToLink.
    substituteInPlace dde-bluetooth-dialog/src/main.cpp \
      dde-hints-dialog/src/main.cpp \
      dde-license-dialog/src/main.cpp \
      dde-license-dialog/src/content.cpp \
      dde-lowpower/src/main.cpp \
      dde-suspend-dialog/src/main.cpp \
      dde-touchscreen-dialog/src/main.cpp \
      dde-warning-dialog/src/main.cpp \
      dde-welcome/src/main.cpp \
      dde-wm-chooser/src/main.cpp \
      dmemory-warning-dialog/src/main.cpp \
      deepin-login-reminder/main.cpp \
      --replace-fail '/usr/share/dde-session-ui/translations' '/run/current-system/sw/share/dde-session-ui/translations'

    substituteInPlace widgets/fullscreenbackground.cpp \
      --replace-fail '/usr/share/wallpapers/deepin/desktop.jpg' '/run/current-system/sw/share/wallpapers/deepin/desktop.jpg' \
      --replace-fail '/usr/share/backgrounds/default_background.jpg' '/run/current-system/sw/share/backgrounds/default_background.jpg'

    # dde-blackwidget shows the shutdown logo / plymouth theme.
    substituteInPlace dde-blackwidget/src/window.cpp \
      --replace-fail '/usr/share/deepin/uos_logo.svg' '/run/current-system/sw/share/deepin/uos_logo.svg' \
      --replace-fail '/usr/share/plymouth/themes/' '/run/current-system/sw/share/plymouth/themes/'

    # The notification action and the second translation dir were missed by the
    # old /usr/share-only rewrite.
    substituteInPlace deepin-login-reminder/main.cpp \
      --replace-fail '/usr/local/share/dde-session-ui/translations' '/run/current-system/sw/share/dde-session-ui/translations' \
      --replace-fail '/usr/bin/dde-hints-dialog' "$out/bin/dde-hints-dialog"

    # Daemon binaries live in $out/lib/deepin-daemon, CLI ones in $out/bin.
    substituteInPlace dde-blackwidget/misc/systemd/user/dde-blackwidget.service \
      dde-blackwidget/misc/systemd/user/dde-blackwidget-nodbus.service \
      --replace-fail '/usr/lib/deepin-daemon/dde-blackwidget' "$out/lib/deepin-daemon/dde-blackwidget"
    substituteInPlace dde-warning-dialog/src/org.deepin.dde.WarningDialog1.service \
      --replace-fail '/usr/lib/deepin-daemon/dde-warning-dialog' "$out/lib/deepin-daemon/dde-warning-dialog"
    substituteInPlace dde-welcome/src/org.deepin.dde.Welcome1.service \
      --replace-fail '/usr/lib/deepin-daemon/dde-welcome' "$out/lib/deepin-daemon/dde-welcome"
    substituteInPlace deepin-login-reminder/deepin-login-reminder.desktop \
      --replace-fail '/usr/bin/deepin-login-reminder' "$out/bin/deepin-login-reminder"

    # /etc/xdg/autostart is not covered by CMAKE_INSTALL_SYSCONFDIR.
    substituteInPlace deepin-login-reminder/CMakeLists.txt \
      --replace-fail '/etc/xdg/autostart/' "$out/etc/xdg/autostart/"
    # The unit dir would otherwise come from systemd.pc and point back into
    # systemd's store path; -DSYSTEMD_USER_UNIT_DIR takes over instead.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'pkg_get_variable(SYSTEMD_USER_UNIT_DIR systemd systemd_user_unit_dir)' \
                     '# SYSTEMD_USER_UNIT_DIR is passed via cmakeFlags'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
    deepin-gettext-tools
  ];

  buildInputs = [
    # Qt6
    qt6Packages.qtbase
    qt6Packages.qtsvg
    qt6Packages.qtdeclarative

    # DTK6
    dtkcore
    dtkwidget
    dtkcommon

    # System
    glib
    xcbutilwm
    libxrandr
    systemd
    gtest
    deepin-pw-check
    libxcrypt
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DDTK_VERSION_MAJOR=6"
    "-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
  ];

  meta = {
    description = "Session UI dialogs for DDE (warnings, low power, welcome, bluetooth, etc.)";
    homepage = "https://github.com/linuxdeepin/dde-session-ui";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
