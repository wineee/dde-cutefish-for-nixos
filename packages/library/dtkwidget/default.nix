{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkgui,
  cups,
  libstartup_notification,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtkwidget";
  version = "6.7.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dtkwidget";
    rev = finalAttrs.version;
    hash = "sha256-TsBRuDaylxEAFDHDKmXqJyizQRBpErBh7FSH33l6h7Q=";
  };

  patches = [
    ./fix-pkgconfig-path.patch
    ./fix-pri-path.patch
  ];

  postPatch = ''
    substituteInPlace src/widgets/dapplication.cpp \
      --replace-fail "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);" \
                "auto dataDirs = DStandardPaths::standardLocations(QStandardPaths::GenericDataLocation) << \"$out/share\";"
    # Optional third-party print-preview settings plugins. NixOS has no
    # /usr/share; point at the system profile where a module could link them.
    substituteInPlace src/widgets/dprintpreviewdialog.cpp \
      --replace-fail '"/usr/share/deepin/dtk/plugins/printsupport"' '"/run/current-system/sw/share/deepin/dtk/plugins/printsupport"'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    cups
    libstartup_notification
  ]
  ++ (with qt6Packages; [
    qtbase
    qtmultimedia
    qtsvg
  ]);

  propagatedBuildInputs = [ dtkgui ];

  cmakeFlags = [
    "-DDTK5=OFF"
    "-DBUILD_DOCS=OFF"
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_PLUGINS=OFF"
    "-DMKSPECS_INSTALL_DIR=${placeholder "dev"}/mkspecs/modules"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${lib.getBin qt6Packages.qtbase}/${qt6Packages.qtbase.qtPluginPrefix}
  '';

  outputs = [
    "out"
    "dev"
  ];

  postFixup = ''
    for binary in $out/lib/dtk6/DWidget/bin/*; do
      wrapQtApp $binary
    done
  '';

  meta = {
    description = "Deepin graphical user interface library";
    homepage = "https://github.com/linuxdeepin/dtkwidget";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
