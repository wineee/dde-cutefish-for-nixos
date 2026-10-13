{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  kdePackages,
  dtkcommon,
  dtkcore,
  dtkgui,
  dtkwidget,
  libx11,
  libxcb,
  libxcursor,
  libxtst,
  xcbutilimage,
  xcbutilwm,
  xcbutil,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-tray-loader";
  version = "2.0.27";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-tray-loader";
    rev = finalAttrs.version;
    hash = "sha256-SFgxrydRScRhg9KZcTods/uPDV9XId0gExAsq7R/6zM=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtsvg
    qt6Packages.qtwayland
    kdePackages.kwindowsystem
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    libx11
    libxcb
    libxcursor
    libxtst
    xcbutilimage
    xcbutilwm
    xcbutil
  ];

  cmakeFlags = [
    "-DDTL_BUILD_WITH_QT6=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = {
    description = "System tray loader for DDE shell";
    homepage = "https://github.com/linuxdeepin/dde-tray-loader";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
