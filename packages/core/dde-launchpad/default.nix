{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  glib,
  systemd,
  appstream,
  kdePackages,
  dtkcommon,
  dtkcore,
  dtkgui,
  dtkdeclarative,
  dde-shell,
  dde-application-manager,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-launchpad";
  version = "2.0.49";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-launchpad";
    rev = finalAttrs.version;
    hash = "sha256-yWteXKN7keDlxo0st/LdOTSLjeHe2ojj5ueeUD2sepc=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtsvg
    qt6Packages.qtwayland
    qt6Packages.qt5compat
    glib
    systemd
    appstream
    kdePackages.appstream-qt
    dtkcommon
    dtkcore
    dtkgui
    dtkdeclarative
    dde-shell
    dde-application-manager
  ];

  # Redirect dde-shell paths and the Qt QML module dir (defaults to qtbase's
  # read-only ${qtbase}/lib/qt-6/qml) into our output.
  postConfigure = ''
    find . -name "cmake_install.cmake" -exec sed -i \
      -e "s|${dde-shell}/share/dde-shell|$out/share/dde-shell|g" \
      -e "s|${dde-shell}/lib/dde-shell|$out/lib/dde-shell|g" \
      -e "s|${qt6Packages.qtbase}/${qt6Packages.qtbase.qtQmlPrefix}|$out/lib/qt6/qml|g" {} +
  '';

  # No on-disk qmldir needed: all three modules are resource-embedded in
  # launchpadcommon.so under /qt/qml/..., found via Qt's default "qrc:/qt/qml"
  # import path. $out/lib/qt6/qml is on no import path anyway (no bin/, no wrapper).

  cmakeFlags = [
    "-DBUILD_TEST=OFF"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
  ];

  meta = {
    description = "Application launcher for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-launchpad";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
