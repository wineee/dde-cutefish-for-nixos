{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkcore,
  dtkgui,
  dtkwidget,
  dtkdeclarative,
  util-dfm,
  deepin-service-manager,
  dde-tray-loader,
  dde-shell,
  deepin-pdfium,
  ffmpeg,
  ffmpegthumbnailer,
  taglib,
  icu,
  libjpeg,
  lucenepp,
  boost,
  glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-grand-search";
  version = "6.1.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-grand-search";
    rev = finalAttrs.version;
    hash = "sha256-A4g4LnxwK7jkVaBQ0FF9Kgsd2T3H9TKNg+/M5jTi6B8=";
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
    qt6Packages.qt5compat
    dtkcore
    dtkgui
    dtkwidget
    dtkdeclarative
    util-dfm
    deepin-service-manager
    dde-tray-loader
    dde-shell
    deepin-pdfium
    ffmpeg
    ffmpegthumbnailer
    taglib
    icu
    libjpeg
    lucenepp
    boost
    glib
  ];

  postPatch = ''
    # Fix hardcoded /usr paths
    find . -name "CMakeLists.txt" -exec sed -i \
      -e "s|/usr/bin|$out/bin|g" \
      -e "s|/usr/share|$out/share|g" \
      -e "s|/usr/lib|$out/lib|g" {} +

    # Fix D-Bus service files
    find . -name "*.service" -exec sed -i \
      -e "s|/usr/bin|$out/bin|g" {} +

    # Skip reading /etc/os-version (NixOS doesn't have it); force DDE 25 so
    # the Qt6-only shell plugin gets built.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'if (NOT DEFINED BUILD_OS_VERSION OR BUILD_OS_VERSION STREQUAL "")' \
                      'if (FALSE)'
  '';

  postConfigure = ''
    # Redirect dde-shell package/plugin install dirs to our own output
    # (ds_install_package resolves DDE_SHELL_PACKAGE_INSTALL_DIR into the
    # dde-shell store path).
    find . -name "cmake_install.cmake" -exec sed -i \
      -e "s|${dde-shell}/share/dde-shell|$out/share/dde-shell|g" \
      -e "s|${dde-shell}/lib/dde-shell|$out/lib/dde-shell|g" {} +
  '';

  cmakeFlags = [
    "-DVERSION=${finalAttrs.version}"
    "-DBUILD_OS_VERSION=25"
  ];

  meta = {
    description = "System-wide desktop search for DDE";
    homepage = "https://github.com/linuxdeepin/dde-grand-search";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
