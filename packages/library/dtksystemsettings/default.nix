{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkcore,
  libxcrypt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtksystemsettings";
  version = "6.6.22";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dtksystemsettings";
    rev = finalAttrs.version;
    hash = "sha256-bGTWGFV6MUfvbY2Rppyd2nI69M+vQyES+cNciBc9XJI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
  ];

  dontWrapQtApps = true;

  buildInputs = [
    qt6Packages.qtbase
    dtkcore
    libxcrypt
  ];

  cmakeFlags = [
    "-DDTK5=OFF"
    "-DBUILD_DOCS=OFF"
    "-DBUILD_EXAMPLES=OFF"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DDTK_INCLUDE_INSTALL_DIR=${placeholder "dev"}/include/dtk/DSystemSettings"
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

  meta = {
    description = "Qt-based development library for system settings";
    homepage = "https://github.com/linuxdeepin/dtksystemsettings";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
