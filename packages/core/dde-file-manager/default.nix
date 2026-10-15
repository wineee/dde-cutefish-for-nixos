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
  qt6integration,
  qt6platform-plugins,
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
  minizip,
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
  version = "6.6.6";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-file-manager";
    rev = finalAttrs.version;
    hash = "sha256-lQ1MDuyCJYC7liKboKv8VwlAv3nqHqCw+H5ErUwXy9Q=";
  };

  # The extractor's ocr plugin needs dtk6ocr, whose upstream repo
  # (linuxdeepin/dtk6ocr) no longer exists. A patch fails loudly if upstream
  # reorganises the plugins, unlike the sed it replaces.
  patches = [ ./0001-drop-ocr-extractor-plugin.patch ];

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
    qt6integration
    qt6platform-plugins

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
    minizip
    libxcb
    libX11
    util-linux
    polkit
    cryptsetup
    lvm2
    systemd
    kdePackages.syntax-highlighting
    kdePackages.polkit-qt-1
    kdePackages.kidletime
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
    # Qt 6.11 removed the char16_t overload of QString::arg(); ch.unicode()
    # returns char16_t, so cast to uint to match the integral overload.
    substituteInPlace src/plugins/filemanager/dfmplugin-disk-encrypt-entry/utils/encryptutils.cpp \
      --replace-fail "ch.unicode(), 2, 16" "static_cast<uint>(ch.unicode()), 2, 16"

    # Only two install() rules target /etc in 6.6.6 (the service-group drop-in
    # dir and the diskencrypt udev rules); every other install already uses a
    # relative DESTINATION, so these two cover the whole tree.
    substituteInPlace src/services/CMakeLists.txt \
      --replace-fail 'DESTINATION /etc/systemd/system' "DESTINATION $out/lib/systemd/system"
    substituteInPlace src/services/diskencrypt/CMakeLists.txt \
      --replace-fail 'DESTINATION /etc/udev/rules.d' "DESTINATION $out/lib/udev/rules.d"

    # Hardcoded FHS paths that upstream still ships in 6.6.6 (all confirmed
    # compiled into the built .so files). Data under /usr/share is merged into the
    # system profile by environment.pathsToLink in the NixOS module.
    substituteInPlace assets/scripts/file-manager.sh \
      --replace-fail "/usr/libexec/dde-file-manager" "$out/libexec/dde-file-manager"

    substituteInPlace src/plugins/filemanager/dfmplugin-vault/utils/vaultdefine.h \
      --replace-fail "/usr/bin/deepin-compressor" "deepin-compressor"

    substituteInPlace src/plugins/filemanager/dfmplugin-avfsbrowser/utils/avfsutils.cpp \
      --replace-fail "/usr/bin/mountavfs" "mountavfs" \
      --replace-fail "/usr/bin/umountavfs" "umountavfs"

    substituteInPlace src/plugins/common/dfmplugin-menu/extendmenuscene/extendmenu/dcustomactionparser.cpp \
      src/plugins/common/dfmplugin-menu/oemmenuscene/oemmenu.cpp \
      --replace-fail "/usr/etc/deepin" "$out/etc/deepin"

    substituteInPlace src/tools/upgrade/dialog/processdialog.cpp \
      --replace-fail "/usr/libexec/dde-file-manager" "$out/libexec/dde-file-manager" \
      --replace-fail "/usr/bin/dde-shell" "${dde-shell}/bin/dde-shell"

    substituteInPlace src/dfm-base/file/local/localfilehandler.cpp \
      src/plugins/common/dfmplugin-fileoperations/fileoperationsevent/fileoperationseventreceiver.cpp \
      --replace-fail "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"

    substituteInPlace src/plugins/desktop/ddplugin-background/backgroundservice.cpp \
      src/plugins/desktop/ddplugin-wallpapersetting/wallpapersettings.cpp \
      --replace-fail "/usr/share/backgrounds" "/run/current-system/sw/share/backgrounds"

    substituteInPlace src/plugins/desktop/ddplugin-background/backgroundmanager.cpp \
      --replace-fail "/usr/share/wallpapers" "/run/current-system/sw/share/wallpapers"

    substituteInPlace src/plugins/desktop/ddplugin-canvas/watermask/watermaskcontainer.cpp \
      src/plugins/desktop/ddplugin-canvas/watermask/watermasksystem.cpp \
      --replace-fail "/usr/share/deepin" "/run/current-system/sw/share/deepin"

    substituteInPlace src/services/diskencrypt/helpers/crypttabhelper.cpp \
      src/services/diskencrypt/dbus/diskencryptsetup.cpp \
      --replace-fail "/usr/bin/sudo" "/run/wrappers/bin/sudo"

    substituteInPlace src/services/diskencrypt/globaltypesdefine.h \
      --replace-fail "/usr/share/applications/dfm-reencrypt.desktop" \
        "$out/share/applications/dfm-reencrypt.desktop"

    # No DDE_SHELL_*_INSTALL_DIR override: dde-shell exports those relative (see
    # dde-shell/default.nix), so the ds_install_package() call in
    # panel-desktop/CMakeLists.txt already lands in this package's own prefix.

    # libappimage is not packaged in nixpkgs (AppImage thumbnails stay off).
    # Comment out both the find_package call and its link-list entry, and drop
    # the token from the .pc file. Exact targets, so an upstream rename fails the
    # build instead of silently leaving a dangling reference.
    substituteInPlace cmake/DFMLibraryConfig.cmake \
      --replace-fail '            libappimage' \
                     '            # no libappimage in nixpkgs' \
      --replace-fail 'find_package(libappimage REQUIRED)' \
                     '# no libappimage in nixpkgs; AppImage thumbnails stay off'
    substituteInPlace assets/dev/dfm6-base/dfm6-base.pc.in \
      --replace-fail 'Requires.private: libappimage libheif poppler-cpp' \
                     'Requires.private: libheif poppler-cpp'

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

  # Installed .desktop/.policy/.service files keep upstream's /usr paths.
  # /usr/bin/false belongs to entries with SystemdService= (dbus delegates
  # activation to systemd and ignores Exec), so point it at a real file.
  #
  # Deliberately a find over $out and not a list of source files: the installed
  # set comes from dozens of install() rules across the tree, some fed by the
  # build directory, so a hand-maintained list would silently miss whatever
  # upstream adds next — silently broken paths matter more here than the
  # precision --replace-fail would give.
  postInstall = ''
    find $out -type f \( -name "*.desktop" -o -name "*.policy" -o -name "*.service" \) -exec sed -i \
      -e "s|/usr/bin/false|/run/current-system/sw/bin/false|g" \
      -e "s|/usr/bin/|$out/bin/|g" \
      -e "s|/usr/libexec/|$out/libexec/|g" \
      -e "s|/usr/share/|$out/share/|g" \
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
