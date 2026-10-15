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
    # The daemon whitelists D-Bus callers by the *real* executable behind
    # /proc/<pid>/exe, which is the wrapQtAppsHook target, not $out/bin/dde-grand-search.
    # Pointing it at the wrapper script makes every search request fail with
    # "Access denied: Invalid invoker path".
    substituteInPlace src/dde-grand-search-daemon/dbusservice/grandsearchinterface.cpp \
      --replace-fail '"/usr/bin/dde-grand-search"' '"${placeholder "out"}/bin/.dde-grand-search-wrapped"'

    # The control-center search result reuses that desktop entry for its icon.
    substituteInPlace src/grand-search/utils/utils.cpp \
      --replace-fail '/usr/share/applications/dde-control-center.desktop' \
                     '/run/current-system/sw/share/applications/dde-control-center.desktop'

    # Three shipped D-Bus activatable services.
    substituteInPlace src/grand-search/contacts/services/com.deepin.dde.GrandSearch.service \
      src/grand-search/contacts/services/com.deepin.dde.GrandSearchSetting.service \
      src/dde-grand-search-daemon/org.deepin.dde.GrandSearchDaemon.service \
      --replace-fail '/usr/bin/dde-grand-search' "$out/bin/dde-grand-search"

    # Third-party searcher plugins (dde-control-center ships one) live in their
    # own store paths and are only visible through the merged system profile.
    substituteInPlace src/dde-grand-search-daemon/searchplugin/pluginmanager.cpp \
      --replace-fail 'm_loader->setPluginPath({ QString(defaultPath) });' \
                     'm_loader->setPluginPath({ QString(defaultPath), QStringLiteral("/run/current-system/sw/lib/dde-grand-search-daemon/plugins/searcher") });'

    # No DDE_SHELL_*_INSTALL_DIR override: dde-shell exports those relative (see
    # dde-shell/default.nix), so ds_install_package() and
    # ds_handle_package_translation() in grand-search-shell-plugin already
    # install into this package's own prefix.

    # Skip reading /etc/os-version (NixOS doesn't have it); force DDE 25 so
    # the Qt6-only shell plugin gets built.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'if (NOT DEFINED BUILD_OS_VERSION OR BUILD_OS_VERSION STREQUAL "")' \
                      'if (FALSE)'
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
