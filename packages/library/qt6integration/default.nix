{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  dtkwidget,
  qt6Packages,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qt6integration";
  version = "6.0.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "qt6integration";
    rev = finalAttrs.version;
    hash = "sha256-h/UGDpEyRpqAbMksLVRpOLLeMDlOJNiznEFvc+NQON8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    dtkwidget
    qt6Packages.qtbase
    gtest
  ];

  cmakeFlags = [
    "-DDTK_VERSION=${finalAttrs.version}"
    "-DPLUGIN_INSTALL_BASE_DIR=${placeholder "out"}/${qt6Packages.qtbase.qtPluginPrefix}"
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Qt platform theme integration plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt6integration";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
