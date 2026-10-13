{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6Packages,
  dtkcore,
  dtkgui,
  dtkwidget,
  dtkcommon,
  glib,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-app-services";
  version = "1.0.46";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-app-services";
    rev = finalAttrs.version;
    hash = "sha256-/jvOoqpoUl96RKOzEdBsy2pFDb6SuIXMEFpqV0BhpHs=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    dtkcore
    dtkgui
    dtkwidget
    dtkcommon
    glib
    systemd
  ];

  cmakeFlags = [
    "-DDTK_VERSION=6"
    "-DDVERSION=${finalAttrs.version}"
    "-DBUILD_TESTING=OFF"
    "-DBUILD_DOCS=OFF"
    "-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
    "-DCMAKE_CXX_FLAGS=-Wno-error=format"
  ];

  postPatch = ''
    # Disable tests/example (unconditionally added, no BUILD_TESTING guard)
    sed -i '/add_subdirectory.*tests/d' dconfig-center/CMakeLists.txt
    sed -i '/add_subdirectory.*example/d' dconfig-center/CMakeLists.txt

    # Fix hardcoded /usr paths
    find . -name "CMakeLists.txt" -exec sed -i \
      -e "s|/etc/|$out/etc/|g" \
      -e "s|/usr/share|$out/share|g" \
      -e "s|/usr/lib|$out/lib|g" \
      -e "s|/usr/bin|$out/bin|g" {} +

    # Fix D-Bus and systemd service files (including .in templates)
    find . \( -name "*.service" -o -name "*.service.in" \) -exec sed -i \
      -e "s|/usr/bin|$out/bin|g" \
      -e "s|/usr/lib|$out/lib|g" \
      -e "s|/usr/share/dsg|/run/current-system/sw/share/dsg|g" {} +

    # Fix systemd unit paths
    find . -name "CMakeLists.txt" -exec sed -i \
      -e 's|''${systemd_USER_UNIT_DIR}|'"$out/lib/systemd/user"'|g' \
      -e 's|''${SYSTEMD_USER_UNIT_DIR}|'"$out/lib/systemd/user"'|g' {} +
  '';

  meta = {
    description = "DDE application services (DConfig center)";
    homepage = "https://github.com/linuxdeepin/dde-app-services";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
