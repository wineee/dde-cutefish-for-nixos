{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkwidget,
  qt6integration,
  qt6platform-plugins,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-draw";
  version = "6.5.43";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-draw";
    rev = finalAttrs.version;
    hash = "sha256-C7Bv/PY1wrJS7wsbF8ozczouyRxWCM7na5Swnb/FFOY=";
  };

  postPatch = ''
    substituteInPlace com.deepin.Draw.service \
      --replace-fail "/usr/bin/deepin-draw" "$out/bin/deepin-draw"
  '';

  nativeBuildInputs = [
    cmake
    qt6Packages.qttools
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6integration
    qt6Packages.qtsvg
    dtkwidget
    qt6platform-plugins
  ];

  cmakeFlags = [ "-DVERSION=${finalAttrs.version}" ];

  strictDeps = true;

  meta = {
    description = "Lightweight drawing tool for users to freely draw and simply edit images";
    mainProgram = "deepin-draw";
    homepage = "https://github.com/linuxdeepin/deepin-draw";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
