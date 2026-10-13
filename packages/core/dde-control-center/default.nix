{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6Packages,
  kdePackages,
  dtkcore,
  dtkgui,
  dtkcommon,
  dde-shell,
  deepin-pw-check,
  treeland-protocols,
  deepin-gettext-tools,
  glib,
  gtest,
  systemd,
  libxcrypt,
  icu,
  openssl,
  dpkg,
  wayland,
  wlr-protocols,
  ffmpegthumbnailer,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-control-center";
  version = "6.1.110";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-control-center";
    rev = finalAttrs.version;
    hash = "sha256-YWWguQNJXUaXn0r7p7ZEBjwIvl67bzYtj9m31lfxxhw=";
  };

  postPatch = ''
    # Fix hardcoded paths
    find . -name "*.cpp" -o -name "*.h" -o -name "*.qml" | xargs sed -i \
      -e 's|/usr/share|/run/current-system/sw/share|g' \
      -e 's|/usr/lib|/run/current-system/sw/lib|g' \
      -e 's|/usr/bin|/run/current-system/sw/bin|g' || true

    find . -name "*.service" -o -name "*.desktop" | xargs sed -i \
      -e "s|/usr/bin|$out/bin|g" \
      -e "s|/usr/lib|$out/lib|g" || true

    # Fix CMake install paths
    find . -name "CMakeLists.txt" -exec sed -i \
      -e "s|/etc/|$out/etc/|g" \
      -e 's|''${systemd_USER_UNIT_DIR}|'"$out/lib/systemd/user"'|g' \
      -e 's|''${SYSTEMD_USER_UNIT_DIR}|'"$out/lib/systemd/user"'|g' {} +

    # nixpkgs passes CMAKE_INSTALL_LIBDIR/DATAROOTDIR as absolute paths, so the
    # config template would double the prefix. Consume them as-is.
    substituteInPlace misc/DdeControlCenterConfig.cmake.in \
      --replace-fail '@CMAKE_INSTALL_PREFIX@/@DCC_PLUGINS_INSTALL_DIR@' '@DCC_PLUGINS_INSTALL_DIR@' \
      --replace-fail '@CMAKE_INSTALL_PREFIX@/@DCC_TRANSLATION_INSTALL_DIR@' '@DCC_TRANSLATION_INSTALL_DIR@'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
    deepin-gettext-tools
  ];

  buildInputs = [
    # Qt6
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtmultimedia
    qt6Packages.qtwayland
    qt6Packages.qtsvg

    # DTK6
    dtkcore
    dtkgui
    dtkcommon

    # DDE
    dde-shell
    deepin-pw-check
    treeland-protocols

    # KDE
    kdePackages.polkit-qt-1

    # System
    glib
    gtest
    systemd
    libxcrypt
    icu
    openssl
    dpkg
    wayland
    wlr-protocols
    ffmpegthumbnailer
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DBUILD_DOCS=OFF"
    "-DDTK_VERSION_MAJOR=6"
    "-DQT_VERSION_MAJOR=6"
    "-DDISABLE_AUTHENTICATION=ON"
    "-DENABLE_WARNINGS_AS_ERRORS=OFF"
  ];

  meta = {
    description = "Control center for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-control-center";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
