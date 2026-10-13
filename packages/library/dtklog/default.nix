{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  spdlog,
  systemd,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtklog";
  version = "6.7.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dtklog";
    rev = finalAttrs.version;
    hash = "sha256-yjRapg6mNq0edPj5nLJ+wcqqsuEODdPV8+AgRJk6QNQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  dontWrapQtApps = true;

  buildInputs = [
    qt6Packages.qtbase
    spdlog
  ]
  ++ lib.optional withSystemd systemd;

  cmakeFlags = [
    (lib.cmakeBool "DTK5" false)
    (lib.cmakeBool "BUILD_WITH_SYSTEMD" withSystemd)
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
  ];

  meta = {
    description = "Simple, convinient and thread safe logger for Qt-based C++ apps";
    homepage = "https://github.com/linuxdeepin/dtklog";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
