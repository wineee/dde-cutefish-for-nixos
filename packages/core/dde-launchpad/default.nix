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

  # The log config is read by deepin-log-viewer (outside this repo) to locate
  # the process behind each submodule filter.
  postPatch = ''
    substituteInPlace dist/deepin-log-config/org.deepin.dde.launchpad.json \
      --replace-fail '/usr/bin/dde-shell' '${dde-shell}/bin/dde-shell'
  '';

  # No on-disk qmldir and no QML install dir: all three QML modules are
  # resource-embedded in launchpadcommon.so under /qt/qml/..., found via Qt's
  # default "qrc:/qt/qml" import path. The postConfigure that used to redirect
  # qtbase's lib/qt-6/qml into $out/lib/qt6/qml therefore never matched anything
  # (and that destination is on no import path anyway), so it is gone.

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
