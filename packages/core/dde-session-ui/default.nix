{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6Packages,
  dtkcore,
  dtkwidget,
  dtkcommon,
  deepin-gettext-tools,
  glib,
  xcbutilwm,
  libxrandr,
  systemd,
  gtest,
  deepin-pw-check,
  libxcrypt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-session-ui";
  version = "6.0.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-session-ui";
    rev = finalAttrs.version;
    hash = "sha256-+1dOzyTrxkKAmRoFhVjz8lVJQfN+8BM0oKwsYa8uLFs=";
  };

  postPatch = ''
    # Fix hardcoded paths
    find . -name "*.cpp" -o -name "*.h" | xargs sed -i \
      -e 's|/usr/share|/run/current-system/sw/share|g' \
      -e 's|/usr/lib|/run/current-system/sw/lib|g' || true

    find . -name "*.service" -o -name "*.desktop" | xargs sed -i \
      -e "s|/usr/bin|$out/bin|g" \
      -e "s|/usr/lib|$out/lib|g" || true

    # Fix CMake install paths
    find . -name "CMakeLists.txt" -exec sed -i \
      -e "s|/etc/|$out/etc/|g" \
      -e "s|/usr/share|$out/share|g" \
      -e 's|''${systemd_USER_UNIT_DIR}|'"$out/lib/systemd/user"'|g' \
      -e 's|''${SYSTEMD_USER_UNIT_DIR}|'"$out/lib/systemd/user"'|g' {} +
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
    qt6Packages.qtsvg
    qt6Packages.qtdeclarative

    # DTK6
    dtkcore
    dtkwidget
    dtkcommon

    # System
    glib
    xcbutilwm
    libxrandr
    systemd
    gtest
    deepin-pw-check
    libxcrypt
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DDTK_VERSION_MAJOR=6"
    "-Dsystemd_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
  ];

  meta = {
    description = "Session UI dialogs for DDE (warnings, low power, welcome, bluetooth, etc.)";
    homepage = "https://github.com/linuxdeepin/dde-session-ui";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
