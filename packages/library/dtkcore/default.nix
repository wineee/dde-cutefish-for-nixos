{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  lshw,
  libuchardet,
  dtkcommon,
  dtklog,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtkcore";
  version = "6.7.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dtkcore";
    rev = finalAttrs.version;
    hash = "sha256-eJDGcqFUykdHSwzaJDnNGsCZFoDGNLfc/KxFoBW+pjA=";
  };

  patches = [
    ./fix-pkgconfig-path.patch
    ./fix-pri-path.patch
  ];

  postPatch = ''
    substituteInPlace misc/DtkCoreConfig.cmake.in \
      --subst-var-by PACKAGE_TOOL_INSTALL_DIR ${placeholder "out"}/libexec/dtk6/DCore/bin
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  dontWrapQtApps = true;

  buildInputs = [
    qt6Packages.qtbase
    lshw
    libuchardet
  ];

  propagatedBuildInputs = [
    dtkcommon
    dtklog
  ];

  cmakeFlags = [
    "-DDTK5=OFF"
    "-DDTK_VERSION=${finalAttrs.version}"
    "-DBUILD_DOCS=OFF"
    "-DBUILD_EXAMPLES=OFF"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DD_DSG_APP_DATA_FALLBACK=/var/dsg/appdata"
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
    for binary in $out/libexec/dtk6/DCore/bin/*; do
      wrapQtApp $binary
    done
  '';

  meta = {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
