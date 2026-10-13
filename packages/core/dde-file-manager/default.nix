{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  kdePackages,
  # DTK
  dtkcore,
  dtkgui,
  dtkwidget,
  dtkdeclarative,
  # DDE
  dde-shell,
  dde-tray-loader,
  deepin-service-manager,
  # File manager deps
  util-dfm,
  deepin-pdfium,
  docparser,
  # System libs
  glib,
  libheif,
  libsecret,
  openssl,
  pcre2,
  icu,
  boost,
  lucenepp,
  poppler,
  openjpeg,
  lcms2,
  ffmpegthumbnailer,
  taglib,
  libxcb,
  libX11,
  util-linux,
  polkit,
  cryptsetup,
  lvm2,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-file-manager";
  version = "6.5.121";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-file-manager";
    rev = finalAttrs.version;
    hash = "sha256-YbKmtDnjzWPz5AFZkwObpzteta5xcJfAdZvNuQ5A2Ro=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    # Qt6
    qt6Packages.qtbase
    qt6Packages.qtsvg
    qt6Packages.qtmultimedia
    qt6Packages.qtdeclarative
    qt6Packages.qt5compat

    # DTK
    dtkcore
    dtkgui
    dtkwidget
    dtkdeclarative

    # DDE
    dde-shell
    dde-tray-loader
    deepin-service-manager

    # File manager specific
    util-dfm
    deepin-pdfium
    docparser

    # System
    glib
    libheif
    libsecret
    openssl
    pcre2
    icu
    boost
    lucenepp
    poppler
    openjpeg
    lcms2
    ffmpegthumbnailer
    taglib
    libxcb
    libX11
    util-linux
    polkit
    cryptsetup
    lvm2
    systemd
    kdePackages.syntax-highlighting
    kdePackages.polkit-qt-1
  ];

  cmakeFlags = [
    "-DVERSION=${finalAttrs.version}"
    "-DOPT_ENABLE_BUILD_UT=OFF"
    "-DOPT_ENABLE_BUILD_DOCS=OFF"
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
    "-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
  ];

  # Fix hardcoded paths and missing deps
  postPatch = ''
    # Fix /etc/ hardcoded paths in services
    find . -name "CMakeLists.txt" -exec sed -i \
      -e "s|DESTINATION /etc/systemd/system|DESTINATION $out/lib/systemd/system|g" \
      -e "s|DESTINATION /etc/udev/rules.d|DESTINATION $out/lib/udev/rules.d|g" \
      -e "s|DESTINATION /etc/|DESTINATION $out/etc/|g" \
      {} +

    # Override dde-shell install dirs after find_package(DDEShell) — the imported
    # cmake config sets non-cache variables pointing to dde-shell's store path
    sed -i '/find_package(DDEShell REQUIRED)/a\
set(DDE_SHELL_PACKAGE_INSTALL_DIR "''${CMAKE_INSTALL_PREFIX}/share/dde-shell")\
set(DDE_SHELL_PLUGIN_INSTALL_DIR "''${CMAKE_INSTALL_PREFIX}/lib/dde-shell")\
set(DDE_SHELL_TRANSLATION_INSTALL_DIR "''${CMAKE_INSTALL_PREFIX}/share/dde-shell")' \
      src/external/dde-shell-plugins/panel-desktop/CMakeLists.txt \
      src/plugins/desktop/ddplugin-core/dependencies.cmake

    # Remove libappimage dependency (not in nixpkgs, used for AppImage thumbnail support)
    sed -i \
      -e 's|find_package(libappimage REQUIRED)|# libappimage removed|' \
      -e 's|libappimage||g' \
      cmake/DFMLibraryConfig.cmake
    sed -i 's|libappimage ||' assets/dev/dfm6-base/dfm6-base.pc.in

    # Stub out appimage thumbnail support in source (libappimage not available)
    substituteInPlace src/dfm-base/utils/thumbnail/thumbnailcreators.cpp \
      --replace-fail '#include <appimage/appimage.h>' '// libappimage removed'
    # Replace the function body to avoid referencing appimage symbols
    substituteInPlace src/dfm-base/utils/thumbnail/thumbnailcreators.cpp \
      --replace-fail 'QImage ThumbnailCreators::appimageThumbnailCreator(const QString &filePath, ThumbnailSize size)' \
        'QImage ThumbnailCreators::appimageThumbnailCreator(const QString &filePath, ThumbnailSize size)
{
    Q_UNUSED(filePath); Q_UNUSED(size);
    return QImage(); // libappimage not available
}
#if 0 // original implementation disabled
QImage _disabled_appimageThumbnailCreator(const QString &filePath, ThumbnailSize size)'
    # Close the #if 0 after the original function's closing brace
    substituteInPlace src/dfm-base/utils/thumbnail/thumbnailcreators.cpp \
      --replace-fail 'QImage ThumbnailCreators::pptxThumbnailCreator' \
        '#endif
QImage ThumbnailCreators::pptxThumbnailCreator'
  '';

  # Fix hardcoded /usr/bin paths in installed service files
  postInstall = ''
    find $out -name "*.service" -exec sed -i \
      -e "s|/usr/bin/dde-file-manager|$out/bin/dde-file-manager|g" \
      -e "s|/usr/bin/dde-desktop|$out/bin/dde-desktop|g" \
      -e "s|/usr/bin/dde-select-dialog|$out/bin/dde-select-dialog|g" \
      -e "s|/usr/bin/dde-file-dialog|$out/bin/dde-file-dialog|g" \
      -e "s|/usr/bin/deepin-diskencrypt-service|$out/bin/deepin-diskencrypt-service|g" \
      -e "s|/usr/bin/deepin-service-manager|${deepin-service-manager}/bin/deepin-service-manager|g" \
      {} +
  '';

  meta = {
    description = "File manager and desktop plugin for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-file-manager";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
