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
  dtkwidget,
  dde-control-center,
  dde-session-shell,
  dde-tray-loader,
  lomiri-qt6,
  glib,
  networkmanager,
  wayland-protocols,
  libsysprof-capture,
  curl,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-network-core";
  version = "2.0.103";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-network-core";
    rev = finalAttrs.version;
    hash = "sha256-Ug2B111zoxndKk4Xng9Anq0amcRqxY8cWPxuofj7z5k=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    # Qt6
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtwayland

    # DTK6
    dtkcore
    dtkwidget

    # DDE
    dde-control-center
    dde-session-shell
    dde-tray-loader
    lomiri-qt6.gsettings-qt

    # KDE
    kdePackages.networkmanager-qt
    kdePackages.extra-cmake-modules

    # System
    glib
    networkmanager
    wayland-protocols
    libsysprof-capture
    curl
    gtest
  ];

  patches = [
    ./fix-paths.patch
  ];

  postPatch = ''
    # Qt translator directories. They are merged into the system profile by
    # environment.pathsToLink (see nixos-modules/deepin/deepin.nix).
    substituteInPlace src/networkcontroller.cpp \
      --replace-fail '/usr/share/dde-network-core/translations' \
                     '/run/current-system/sw/share/dde-network-core/translations'
    substituteInPlace dock-network-plugin/networkplugin.cpp \
      --replace-fail '/usr/share/dock-network-plugin/translations' \
                     '/run/current-system/sw/share/dock-network-plugin/translations'
    substituteInPlace dss-network-plugin/networkmodule.cpp \
      --replace-fail '/usr/share/dss-network-plugin/translations' \
                     '/run/current-system/sw/share/dss-network-plugin/translations'
    substituteInPlace network-service-plugin/src/servicefactory.cpp \
      network-service-plugin/dde-network-secret-dialog/src/main.cpp \
      --replace-fail '/usr/share/deepin-service-manager/network-service/translations' \
                     '/run/current-system/sw/share/deepin-service-manager/network-service/translations'
    # networkinitialization.cpp uses this define in the Release build.
    substituteInPlace network-service-plugin/CMakeLists.txt \
      --replace-fail 'ADD_DEFINITIONS(-DQM_FILES_DIR="/usr/share/deepin-service-manager/network-service/translations")' \
                     'ADD_DEFINITIONS(-DQM_FILES_DIR="/run/current-system/sw/share/deepin-service-manager/network-service/translations")'

    # Notifications resolve the reporting application by its desktop entry.
    substituteInPlace dss-network-plugin/notification/bubbletool.cpp \
      --replace-fail '"/usr/share/applications/"' '"/run/current-system/sw/share/applications/"'

    # The secret dialog and the NetworkManager VPN plugins both live outside
    # the flat FHS layout: the dialog ships with this package, VPN plugins are
    # merged into the profile under lib/.
    substituteInPlace network-service-plugin/src/session/networksecretagent.cpp \
      --replace-fail '"/usr/lib/deepin-daemon/dde-network-secret-dialog"' \
                     '"$out/lib/deepin-daemon/dde-network-secret-dialog"' \
      --replace-fail '"/usr/lib/NetworkManager/VPN/"' \
                     '"/run/current-system/sw/lib/NetworkManager/VPN/"'
  '';

  cmakeFlags = [
    "-DVERSION=${finalAttrs.version}"
    "-DBUILD_TESTS=OFF"
    "-DBUILD_EXAMPLE=OFF"
  ];

  strictDeps = true;

  meta = {
    description = "DDE network library framework";
    homepage = "https://github.com/linuxdeepin/dde-network-core";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
