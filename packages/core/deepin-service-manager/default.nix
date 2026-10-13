{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkcore,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-service-manager";
  version = "1.0.21";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-service-manager";
    rev = finalAttrs.version;
    hash = "sha256-D3igB2sb3Tiqa5gY0ZyOwczMMh6ZMo/gpvLycgZv1LY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    dtkcore
    systemd
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
  ];

  # Override the compile-time plugin config and library search paths.
  # By default, deepin-service-manager hardcodes its own store path for
  # SERVICE_CONFIG_DIR and SERVICE_LIB_DIR.  Other packages (dde-appearance,
  # dde-daemon, etc.) install their plugin JSON configs and .so libraries
  # into their own store paths, which are linked into
  # /run/current-system/sw/ via environment.pathsToLink.
  preConfigure = ''
    sed -i 's|"\''${CMAKE_INSTALL_PREFIX}/share/deepin-service-manager/"|"/run/current-system/sw/share/deepin-service-manager/"|' \
      src/CMakeLists.txt
    sed -i 's|"\''${CMAKE_INSTALL_FULL_LIBDIR}/deepin-service-manager/"|"/run/current-system/sw/lib/deepin-service-manager/"|' \
      src/CMakeLists.txt
  '';

  # Fix hardcoded /usr/bin paths in systemd service files
  postInstall = ''
    find $out -name "*.service" -exec sed -i \
      -e "s|/usr/bin/deepin-service-manager|$out/bin/deepin-service-manager|g" \
      -e "s|/usr/bin/|$out/bin/|g" \
      -e "s|/usr/lib/|$out/lib/|g" \
      {} +
  '';

  meta = {
    description = "D-Bus service manager for Deepin Desktop";
    mainProgram = "deepin-service-manager";
    homepage = "https://github.com/linuxdeepin/deepin-service-manager";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
