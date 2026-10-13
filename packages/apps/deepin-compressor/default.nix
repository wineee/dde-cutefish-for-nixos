{
  stdenv,
  lib,
  fetchFromGitHub,
  dtkwidget,
  qt6integration,
  qt6platform-plugins,
  kdePackages,
  cmake,
  pkg-config,
  qt6Packages,
  minizip,
  libzip,
  libarchive,
  glib,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-compressor";
  version = "6.5.36";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-compressor";
    rev = finalAttrs.version;
    hash = "sha256-hyBdaqZTN1Nur7d8el6QI/F/n9bEqfKtoZM4FsUR5Gg=";
  };

  postPatch = ''
    # fix hardcoded /usr paths
    substituteInPlace src/source/common/pluginmanager.cpp \
      --replace-fail "/usr/lib" "$out/lib"
    substituteInPlace src/desktop/deepin-compressor.desktop \
      --replace-fail "/usr" "$out"
    substituteInPlace src/com.deepin.Compressor.service \
      --replace-fail "/usr/bin/deepin-compressor" "$out/bin/deepin-compressor"
    substituteInPlace 3rdparty/clipzipplugin/clipzipplugin.cpp \
      --replace-fail "/usr/lib/deepin-compressor" "$out/lib/deepin-compressor"

    # -pie in CMAKE_CXX_FLAGS reaches the shared plugin link and breaks on
    # CMake 4.x (undefined reference to main)
    substituteInPlace CMakeLists.txt \
      --replace-fail "-fstack-protector-strong -D_FORTIFY_SOURCE=2 -z noexecstack -pie -fPIC -z lazy" \
                     "-fstack-protector-strong -D_FORTIFY_SOURCE=2 -z noexecstack -fPIC -z lazy"

    # bundled translation-generate.cmake falls back to a hardcoded
    # /lib/qt6/bin/lrelease; use the Qt6::lrelease imported target instead
    substituteInPlace cmake/translation-generate.cmake \
      --replace-fail 'set(QT_LRELEASE "/lib/qt''${QT_VERSION_MAJOR}/bin/lrelease")' \
                     'get_target_property(QT_LRELEASE Qt''${QT_VERSION_MAJOR}::lrelease IMPORTED_LOCATION)'
  '';

  nativeBuildInputs = [
    cmake
    qt6Packages.qttools
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qt6integration
    qt6platform-plugins
    qt6Packages.qtbase
    qt6Packages.qt5compat
    kdePackages.kcodecs
    kdePackages.karchive
    minizip
    libzip
    libarchive
    glib
    util-linux
  ];

  cmakeFlags = [
    "-DVERSION=${finalAttrs.version}"
    "-DUSE_TEST=OFF"
  ];

  strictDeps = true;

  meta = with lib; {
    description = "Fast and lightweight application for creating and extracting archives";
    mainProgram = "deepin-compressor";
    homepage = "https://github.com/linuxdeepin/deepin-compressor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
