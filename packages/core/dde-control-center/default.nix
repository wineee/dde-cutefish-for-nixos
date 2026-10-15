{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6Packages,
  kdePackages,
  dtkcore,
  dtkgui,
  dtkcommon,
  dde-shell,
  deepin-pw-check,
  treeland-protocols,
  deepin-gettext-tools,
  glib,
  glibcLocales,
  gtest,
  systemd,
  libxcrypt,
  icu,
  openssl,
  dpkg,
  wayland,
  wlr-protocols,
  ffmpegthumbnailer,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-control-center";
  version = "6.1.110";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-control-center";
    rev = finalAttrs.version;
    hash = "sha256-YWWguQNJXUaXn0r7p7ZEBjwIvl67bzYtj9m31lfxxhw=";
  };

  postPatch = ''
    # ---- executables the package ships itself ------------------------------
    # bin/dde-control-center is a shell wrapper without a suffix, so a
    # name-based rewrite never touched it: REAL_BINARY kept pointing into
    # /usr/libexec and the control center could not start at all.
    substituteInPlace misc/dde-control-center-loader-wrapper \
      --replace-fail '/usr/libexec/deepin/dde-control-center' "$out/libexec/deepin/dde-control-center" \
      --replace-fail '/usr/bin/deepin-security-loader' '/run/current-system/sw/bin/deepin-security-loader'

    substituteInPlace misc/org.deepin.dde.control-center.desktop \
      --replace-fail '/usr/bin/dde-control-center' "$out/bin/dde-control-center"

    # deepin-log-viewer (external) matches journal entries through this field.
    substituteInPlace misc/deepin-log-config/org.deepin.dde.control-center.json \
      --replace-fail '/usr/bin/dde-control-center' "$out/bin/dde-control-center"

    # ---- data merged into /run/current-system by environment.pathsToLink --
    substituteInPlace src/dde-control-center/securityloaderhelper.cpp \
      --replace-fail '/usr/share/dde-control-center/permission-interfaces' '/run/current-system/sw/share/dde-control-center/permission-interfaces'
    substituteInPlace src/plugin-defaultapp/qml/DetailItem.qml \
      --replace-fail '"/usr/share/applications"' '"/run/current-system/sw/share/applications"'
    # The dcc-setting icons are shipped by dde-shell / dde-tray-loader /
    # dde-network-core, the wallpapers by deepin-wallpapers.
    substituteInPlace src/plugin-dock/operation/dccdockexport.cpp \
      --replace-fail '/usr/share/dde-dock/icons/dcc-setting' '/run/current-system/sw/share/dde-dock/icons/dcc-setting'
    substituteInPlace src/plugin-personalization/operation/wallpaperprovider.cpp \
      src/plugin-display/operation/private/displayworker.cpp \
      --replace-fail '/usr/share/wallpapers/' '/run/current-system/sw/share/wallpapers/'
    substituteInPlace src/plugin-display/operation/private/displayworker.cpp \
      --replace-fail '/usr/share/dde-wloutput-daemon/' '/run/current-system/sw/share/dde-wloutput-daemon/'
    substituteInPlace src/plugin-power/operation/powerworker.cpp \
      src/plugin-systeminfo/operation/utils.h \
      --replace-fail '/usr/share/dde-control-center/dde-control-center.conf' '/run/current-system/sw/share/dde-control-center/dde-control-center.conf'

    # License texts: expected from deepin-desktop-base / deepin-deepinid-client,
    # neither of which is packaged here yet. Map them anyway so a future package
    # lands in the right place instead of patching every consumer again.
    substituteInPlace src/plugin-commoninfo/operation/commoninfowork.cpp \
      src/plugin-systeminfo/operation/systeminfowork.cpp \
      src/plugin-systeminfo/operation/utils.h \
      --replace-fail '/usr/share/protocol/' '/run/current-system/sw/share/protocol/' \
      --replace-fail '/usr/share/deepin-deepinid-client/' '/run/current-system/sw/share/deepin-deepinid-client/'

    # deepin-defender / deepin-immutable-writable / uengine are optional
    # external helpers; /run/current-system/sw/bin is their NixOS home.
    substituteInPlace src/plugin-commoninfo/operation/commoninfowork.cpp \
      --replace-fail '/usr/libexec/deepin/deepin-defender' '/run/current-system/sw/libexec/deepin/deepin-defender' \
      --replace-fail '/usr/bin/deepin-immutable-writable' '/run/current-system/sw/bin/deepin-immutable-writable'

    # dpkg is a build input; /usr/bin/dpkg does not exist on NixOS.
    substituteInPlace src/plugin-privacy/operation/privacysecurityworker.cpp \
      --replace-fail '"/usr/bin/dpkg"' '"${dpkg}/bin/dpkg"' \
      --replace-fail '"/usr/bin/dpkg-query"' '"${dpkg}/bin/dpkg-query"' \
      --replace-fail '/usr/bin/uengine-launch.sh' '/run/current-system/sw/bin/uengine-launch.sh'

    # NixOS exposes tzdata at /etc/zoneinfo, never /usr/share/zoneinfo.
    substituteInPlace src/plugin-datetime/operation/timezoneMap/timezone.cpp \
      --replace-fail '"/usr/share/zoneinfo"' '"/etc/zoneinfo"'

    # The installed CMake macro documents the old translation directory in a
    # comment; keep artifact scans free of stale /usr literals.
    substituteInPlace misc/DdeControlCenterPluginMacros.cmake \
      --replace-fail '/usr/share/dde-control-center/translations/xxx.qm' 'share/dde-control-center/translations/xxx.qm'

    # nixpkgs passes CMAKE_INSTALL_LIBDIR as an absolute path, so the exported
    # config template would otherwise double the prefix.
    substituteInPlace misc/DdeControlCenterConfig.cmake.in \
      --replace-fail '@CMAKE_INSTALL_PREFIX@/@DCC_PLUGINS_INSTALL_DIR@' '@DCC_PLUGINS_INSTALL_DIR@' \
      --replace-fail '@CMAKE_INSTALL_PREFIX@/@DCC_TRANSLATION_INSTALL_DIR@' '@DCC_TRANSLATION_INSTALL_DIR@'
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
    qt6Packages.qtdeclarative
    qt6Packages.qtmultimedia
    qt6Packages.qtwayland
    qt6Packages.qtsvg

    # DTK6
    dtkcore
    dtkgui
    dtkcommon

    # DDE
    dde-shell
    deepin-pw-check
    treeland-protocols

    # KDE
    kdePackages.polkit-qt-1

    # System
    glib
    gtest
    systemd
    libxcrypt
    icu
    openssl
    dpkg
    wayland
    wlr-protocols
    ffmpegthumbnailer
  ];

  # systemd.pc points systemduserunitdir back into systemd's read-only store
  # path, but the CMakeLists honours this variable when it is predefined. The
  # move-systemd-user-units.sh hook then relocates it to share/systemd/user.
  env.PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DBUILD_DOCS=OFF"
    "-DDTK_VERSION_MAJOR=6"
    "-DQT_VERSION_MAJOR=6"
    "-DDISABLE_AUTHENTICATION=ON"
    "-DENABLE_WARNINGS_AS_ERRORS=OFF"
    # Third-party panels such as dde-network-core's live in their own store
    # paths; main.cpp builds its plugin search path from this directory, and
    # MODULE_READ_DIR is what the pre-removal nixpkgs package used as well.
    "-DMODULE_READ_DIR=/run/current-system/sw/lib/dde-control-center"
    # glibcLocales ships the SUPPORTED locale list the datetime plugin parses;
    # there is no /usr/share/i18n on NixOS.
    "-DLOCALE_I18N_PATH=${glibcLocales}/share/i18n/SUPPORTED"
  ];

  meta = {
    description = "Control center for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-control-center";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
