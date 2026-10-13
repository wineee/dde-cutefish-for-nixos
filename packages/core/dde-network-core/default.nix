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
