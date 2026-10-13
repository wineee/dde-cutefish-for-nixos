{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkcommon,
  dtkcore,
  librsvg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtkgui";
  version = "6.7.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dtkgui";
    rev = finalAttrs.version;
    hash = "sha256-McPspHK2F5rrO339LJrgw8XDuTGMFaJO9/QCpwPxrOU=";
  };

  patches = [
    ./fix-pkgconfig-path.patch
    ./fix-pri-path.patch
  ];

  postPatch = ''
    substituteInPlace src/util/dsvgrenderer.cpp \
      --replace-fail 'QLibrary("rsvg-2", "2")' 'QLibrary("${lib.getLib librsvg}/lib/librsvg-2.so")'
    substituteInPlace src/kernel/kernel.cmake \
      --replace-fail '/usr/share/dsg/configs/org.deepin.dtk.preference.json' '${dtkcommon}/share/dsg/configs/org.deepin.dtk.preference.json'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtwayland
    librsvg
  ];

  propagatedBuildInputs = [
    dtkcore
    qt6Packages.qtimageformats
  ];

  cmakeFlags = [
    "-DDTK5=OFF"
    "-DBUILD_DOCS=OFF"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
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
    for binary in $out/libexec/dtk6/DGui/bin/*; do
      wrapQtApp $binary
    done
  '';

  meta = {
    description = "Deepin Toolkit, gui module for DDE look and feel";
    homepage = "https://github.com/linuxdeepin/dtkgui";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
