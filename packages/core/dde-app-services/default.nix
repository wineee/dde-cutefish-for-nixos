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
    # tests/example are added unconditionally (no BUILD_TESTING guard).
    substituteInPlace dconfig-center/CMakeLists.txt \
      --replace-fail 'add_subdirectory("example")' '# example: disabled for NixOS' \
      --replace-fail 'add_subdirectory("tests")' '# tests: disabled for NixOS'

    # DSG metadata comes from many packages and is merged into the system
    # profile, so the CLI tools must not fall back to the FHS dir.
    substituteInPlace dconfig-center/dde-dconfig/main.cpp \
      dconfig-center/dde-dconfig-editor/main.cpp \
      --replace-fail '"/usr/share/dsg:/var/lib/linglong/entries/share/dsg"' \
                     '"/run/current-system/sw/share/dsg"'

    substituteInPlace dconfig-center/dde-dconfig-daemon/services/dde-dconfig-daemon.service \
      --replace-fail "/usr/bin/dde-dconfig-daemon" "$out/bin/dde-dconfig-daemon" \
      --replace-fail "DSG_DATA_DIRS=/usr/share/dsg:/var/lib/linglong/entries/share/dsg" \
                     "DSG_DATA_DIRS=/run/current-system/sw/share/dsg" \
      --replace-fail "ReadOnlyPaths=/usr/share/dsg -/var/lib/linglong/entries/share/dsg" \
                     "ReadOnlyPaths=/run/current-system/sw/share/dsg"

    substituteInPlace dconfig-center/dde-dconfig-daemon/services/org.desktopspec.ConfigManager.service \
      dconfig-center/dde-dconfig-daemon/misc/deepin-log-config/dde-dconfig-daemon.json \
      --replace-fail "/usr/bin/dde-dconfig-daemon" "$out/bin/dde-dconfig-daemon"
  '';

  meta = {
    description = "DDE application services (DConfig center)";
    homepage = "https://github.com/linuxdeepin/dde-app-services";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
