{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkgui,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtkdeclarative";
  version = "6.7.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dtkdeclarative";
    rev = finalAttrs.version;
    hash = "sha256-x62jzHrEcIFeMettwpCp6xdE9m2OsLJjwT8l53+B4gM=";
  };

  patches = [
    ./fix-pkgconfig-path.patch
    ./fix-pri-path.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  propagatedBuildInputs = [
    dtkgui
  ]
  ++ (with qt6Packages; [
    qtbase
    qtdeclarative
    qtshadertools
    qt5compat
  ]);

  cmakeFlags = [
    "-DDTK5=OFF"
    "-DBUILD_DOCS=OFF"
    "-DBUILD_EXAMPLES=OFF"
    "-DMKSPECS_INSTALL_DIR=${placeholder "dev"}/mkspecs/modules"
    "-DQML_INSTALL_DIR=${placeholder "out"}/${qt6Packages.qtbase.qtQmlPrefix}"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${lib.getBin qt6Packages.qtbase}/${qt6Packages.qtbase.qtPluginPrefix}
    export QML2_IMPORT_PATH=${lib.getBin qt6Packages.qtdeclarative}/${qt6Packages.qtbase.qtQmlPrefix}
  '';

  outputs = [
    "out"
    "dev"
  ];

  meta = {
    description = "Widget development toolkit based on QtQuick/QtQml";
    mainProgram = "dtk-exhibition";
    homepage = "https://github.com/linuxdeepin/dtkdeclarative";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
