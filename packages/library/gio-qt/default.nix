{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  glibmm_2_4,
  doxygen,
  buildDocs ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gio-qt";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "gio-qt";
    rev = finalAttrs.version;
    hash = "sha256-O8ZWtkwpafiThxa0Wp4xogcouAbHUsR6ZBU256LNRWI=";
  };

  # Upstream builds both qt5 and qt6 versions, which conflicts with
  # qt6 hooks (no qt5 available in this scope). Keep only qt6.
  postPatch = ''
    substituteInPlace gio-qt/CMakeLists.txt qgio-tools/CMakeLists.txt \
      --replace-fail "include(qt5.cmake)" " "
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ]
  ++ lib.optionals buildDocs [
    doxygen
    qt6Packages.qttools
  ];

  buildInputs = [
    qt6Packages.qtbase
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DPROJECT_VERSION=${finalAttrs.version}"
    (lib.cmakeBool "BUILD_DOCS" buildDocs)
    (lib.cmakeBool "BUILD_UTILS" false)
    (lib.cmakeBool "BUILD_TESTS" false)
  ];

  propagatedBuildInputs = [ glibmm_2_4 ];

  dontWrapQtApps = true;

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${lib.getBin qt6Packages.qtbase}/${qt6Packages.qtbase.qtPluginPrefix}
  '';

  meta = {
    description = "Gio wrapper for Qt applications";
    homepage = "https://github.com/linuxdeepin/gio-qt";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.deepin ];
  };
})
