{
  stdenv,
  lib,
  fetchFromGitLab,
  gitUpdater,
  testers,
  cmake,
  pkgs,
  glib,
  libglvnd,
  pkg-config,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gsettings-qt6";
  version = "1.1.1";

  src = fetchFromGitLab {
    owner = "ubports";
    repo = "development/core/gsettings-qt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JgfDa4MStNyG84PmJNOC+1x/wwQiJpJwWV9XVwzkWYw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qtdeclarative
  ];

  buildInputs = [
    pkgs.lomiri.cmake-extras
    glib
    libglvnd
  ];

  # Library
  dontWrapQtApps = true;

  postPatch =
    # Upstream renamed WERROR option to ENABLE_WERROR, but forgot this line
    ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'if (WERROR)' 'if (ENABLE_WERROR)'
    ''
    # The usual pkg-config fix
    + ''
      substituteInPlace src/gsettings-qt.pc.in \
        --replace-fail "\''${prefix}/@CMAKE_INSTALL_LIBDIR@" '@CMAKE_INSTALL_FULL_LIBDIR@' \
        --replace-fail "\''${prefix}/@QT_INCLUDE_DIR@/QGSettings" '@QT_FULL_INCLUDE_DIR@/QGSettings'
    ''
    # Fix Cflags to include both paths:
    # - include/qt6/QGSettings for #include <QGSettings> (deepin-kwin style)
    # - include/qt6 for #include <QGSettings/QGSettings> (Qt style)
    + ''
      substituteInPlace src/gsettings-qt.pc.in \
        --replace-fail 'Cflags: -I''${includedir}' 'Cflags: -I''${includedir} -I@QT_FULL_INCLUDE_DIR@'
    ''
    # Adjust to where we keep QML modules
    + ''
      substituteInPlace GSettings/CMakeLists.txt \
        --replace-fail "\''${CMAKE_INSTALL_LIBDIR}/qt\''${QT_VERSION_MAJOR}/qml" '${placeholder "out"}/${qt6Packages.qtbase.qtQmlPrefix}'
    ''
    # Need QtQuick.Window in QML2_IMPORT_PATH
    + ''
      substituteInPlace tests/CMakeLists.txt \
        --replace-fail 'QML2_IMPORT_PATH=' 'QML2_IMPORT_PATH=${lib.getBin qt6Packages.qtdeclarative}/${qt6Packages.qtbase.qtQmlPrefix}:'
    '';

  preBuild =
    # For qmlplugindump
    ''
      export QT_PLUGIN_PATH=${lib.getBin qt6Packages.qtbase}/${qt6Packages.qtbase.qtPluginPrefix}
    '';

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_QT6" true)
    (lib.cmakeBool "ENABLE_WERROR" true)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  postInstall =
    # *Something* is going wrong when the module path doesn't include the version
    # https://gitlab.com/ubports/development/core/gsettings-qt/-/merge_requests/7#note_2952471601
    ''
      mv -v $out/${qt6Packages.qtbase.qtQmlPrefix}/GSettings $out/${qt6Packages.qtbase.qtQmlPrefix}/GSettings.1.0
    '';

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Library to access GSettings from Qt (Qt6 build)";
    homepage = "https://gitlab.com/ubports/core/gsettings-qt";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;
    pkgConfigModules = [
      "gsettings-qt6"
    ];
    maintainers = with lib.maintainers; [ wineee ];
  };
})
