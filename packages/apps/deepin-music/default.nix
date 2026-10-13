{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  dtkwidget,
  dtkdeclarative,
  dtkcore,
  dtkgui,
  qt6integration,
  qt6platform-plugins,
  qt6mpris,
  ffmpeg_6,
  libvlc,
  qt6Packages,
  taglib,
  SDL2,
  icu,
}:

stdenv.mkDerivation rec {
  pname = "deepin-music";
  version = "7.0.68";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-gZkr0MjXTeFd3h+l+fP0CXCIptscYhDF2FEfOuS3Niw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dtkdeclarative
    dtkcore
    dtkgui
    qt6integration
    qt6platform-plugins
    qt6mpris
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtmultimedia
    qt6Packages.qtsvg
    qt6Packages.qt5compat
    ffmpeg_6
    libvlc
    taglib
    SDL2
    icu
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${lib.getDev libvlc}/include/vlc/plugins"
    "-I${lib.getDev libvlc}/include/vlc"
  ];

  # qtmultimedia can't be found with strictDeps
  strictDeps = false;

  meta = {
    description = "Awesome music player with brilliant and tweakful UI Deepin-UI based";
    mainProgram = "deepin-music";
    homepage = "https://github.com/linuxdeepin/deepin-music";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
