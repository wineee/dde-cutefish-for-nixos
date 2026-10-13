{
  stdenv,
  lib,
  fetchFromGitHub,
  dtkwidget,
  qt6integration,
  qt6platform-plugins,
  qt6Packages,
  cmake,
  pkg-config,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-calculator";
  version = "6.5.40";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-calculator";
    rev = finalAttrs.version;
    hash = "sha256-4Eg6bWn3EPZo65m5UNKD9GViO9WI1iqoBcXjZp3vYfE=";
  };

  nativeBuildInputs = [
    cmake
    qt6Packages.qttools
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qt6integration
    qt6platform-plugins
    qt6Packages.qtbase
    qt6Packages.qtsvg
    gtest
  ];

  # qtsvg can't be found with strictDeps
  strictDeps = false;

  cmakeFlags = [ "-DVERSION=${finalAttrs.version}" ];

  meta = {
    description = "Easy to use calculator for ordinary users";
    mainProgram = "deepin-calculator";
    homepage = "https://github.com/linuxdeepin/deepin-calculator";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
