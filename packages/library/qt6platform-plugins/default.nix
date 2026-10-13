{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  mtdev,
  cairo,
  libsm,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qt6platform-plugins";
  version = "6.0.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "qt6platform-plugins";
    rev = finalAttrs.version;
    hash = "sha256-3Dgm/cVL22fDQAer9EqvRNJKlRwIT1Z62RPiJ7bhgPI=";
  };

  postUnpack = ''
    tar -xf ${qt6Packages.qtbase.src}
    mv qtbase-everywhere-src-${qt6Packages.qtbase.version}/src/plugins/platforms/xcb ${finalAttrs.src.name}/xcb/libqt6xcbqpa-dev/${qt6Packages.qtbase.version}
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    mtdev
    cairo
    libsm
    qt6Packages.qtbase
  ];

  cmakeFlags = [
    "-DDTK_VERSION=${finalAttrs.version}"
    "-DINSTALL_PATH=${placeholder "out"}/${qt6Packages.qtbase.qtPluginPrefix}/platforms"
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Qt platform plugins for DDE";
    homepage = "https://github.com/linuxdeepin/qt6platform-plugins";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
