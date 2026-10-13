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
  version = "1.0.24";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-service-manager";
    rev = finalAttrs.version;
    hash = "sha256-LAIO5bWE8nm/8v6CIoaw4MfQcpUU13+v4srUyqyvScw=";
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

  postPatch = ''
    # SERVICE_CONFIG_DIR / SERVICE_LIB_DIR default to this package's own store
    # path, but plugin JSON and .so come from other packages and are merged
    # into /run/current-system/sw by environment.pathsToLink.
    substituteInPlace src/CMakeLists.txt \
      --replace-fail ''${CMAKE_INSTALL_PREFIX}/share/deepin-service-manager/ /run/current-system/sw/share/deepin-service-manager/ \
      --replace-fail ''${CMAKE_INSTALL_FULL_LIBDIR}/deepin-service-manager/ /run/current-system/sw/lib/deepin-service-manager/

    substituteInPlace misc/deepin-service-manager.service.in \
      misc/deepin-service-group@.service.in \
      misc/deepin-service-plugin@.service.in \
      --replace-fail /usr/bin/deepin-service-manager "$out/bin/deepin-service-manager"

    substituteInPlace misc/deepin-log-config/org.deepin.service.manager.json \
      --replace-fail /usr/bin/deepin-service-manager "$out/bin/deepin-service-manager"
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
