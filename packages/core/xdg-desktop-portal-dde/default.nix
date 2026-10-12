{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  python3,
  qt6Packages,
  kdePackages,
  wayland,
  wayland-scanner,
  wayland-protocols,
  wlr-protocols,
  treeland-protocols,
  libdrm,
  libgbm,
  pipewire,
  dtkcore,
  dtkgui,
  dtkwidget,
  dtkdeclarative,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-dde";
  version = "1.1.11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "xdg-desktop-portal-dde";
    rev = "01f60b022a54ae7d4a512420ff9f256ab3f29ab5";
    hash = "sha256-rRBIj+UHiVhxKWT1BacHnf2BBaaqCipNBdHr+Wh/r04=";
  };

  postPatch = ''
    # Fix hardcoded /usr paths for NixOS.
    #
    # The wayland client scanner needs the core wayland.xml protocol file,
    # which upstream hardcodes to the FHS location /usr/share/wayland/wayland.xml.
    # NixOS's wayland package ships it via wayland-scanner (no wayland.xml in
    # pkgs.wayland.out itself).
    substituteInPlace src/wayland/CMakeLists.txt \
      --replace-fail '/usr/share/wayland/wayland.xml' '${wayland-scanner}/share/wayland/wayland.xml'

    # The systemd user unit is installed to the FHS hardcoded
    # CMAKE_INSTALL_PREFIX/lib/systemd/user. CMAKE_INSTALL_LIBDIR is the
    # GNUInstallDirs-provided location, which Nix's cmake hook points into the
    # output store path (and the move-systemd-user-units hook relocates to
    # share/systemd/user).
    substituteInPlace CMakeLists.txt \
      --replace-fail 'DESTINATION "''${CMAKE_INSTALL_PREFIX}/lib/systemd/user/"' \
                     'DESTINATION "''${CMAKE_INSTALL_LIBDIR}/systemd/user/"'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
    # Required for the Qt6WaylandScannerTools find module used by
    # src/wayland/CMakeLists.txt (and the shared ECM module path).
    kdePackages.extra-cmake-modules
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtwayland
    qt6Packages.qtsvg
    wayland
    wayland-scanner
    wayland-protocols
    wlr-protocols
    treeland-protocols
    libdrm
    libgbm
    pipewire
    dtkcore
    dtkgui
    dtkwidget
    dtkdeclarative
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    # Avoid the upstream /usr default prefix; Nix's cmake hook already sets
    # CMAKE_INSTALL_PREFIX to the output store path.
    (lib.cmakeBool "BUILD_TESTING" false)
  ];

  meta = {
    description = "A DDE (Deepin Desktop Environment) backend implementation for xdg-desktop-portal";
    homepage = "https://github.com/linuxdeepin/xdg-desktop-portal-dde";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xdg-desktop-portal-dde";
    maintainers = with lib.maintainers; [ ];
  };
})
