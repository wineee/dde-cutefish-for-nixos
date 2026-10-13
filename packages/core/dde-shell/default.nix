{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  kdePackages,
  wayland,
  wayland-protocols,
  yaml-cpp,
  icu,
  systemd,
  dtkcommon,
  dtkcore,
  dtkgui,
  dtkwidget,
  dtkdeclarative,
  dde-tray-loader,
  dde-application-manager,
  treeland-protocols,
  libxcb,
  xcbutil,
  xcbutilwm,
  libxtst,
  qt6platform-plugins,
  qt6integration,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-shell";
  version = "2.0.57";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-shell";
    rev = finalAttrs.version;
    hash = "sha256-zp1REp+Cd8Ho8ImCLacyglwspP7h7aPuxSy46vKUsDQ=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtsvg
    qt6Packages.qtwayland
    qt6Packages.qt5compat
    qt6Packages.qtimageformats
    wayland
    wayland-protocols
    yaml-cpp
    icu
    systemd
    dde-tray-loader
    dde-application-manager
    treeland-protocols
    libxcb
    xcbutil
    xcbutilwm
    libxtst
    qt6platform-plugins
    qt6integration
  ];

  propagatedBuildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    dtkdeclarative
  ];

  cmakeFlags = [
    "-DDS_BUILD_WITH_QT6=ON"
    "-DBUILD_WITH_X11=ON"
    "-DBUILD_TESTING=OFF"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
  ];

  postPatch = ''
    # Upstream compiles with -Werror; Qt 6.9 deprecates QSortFilterProxyModel::
    # invalidateFilter() which upstream still calls, so drop -Werror to keep
    # deprecated-declarations warnings non-fatal.
    substituteInPlace CMakeLists.txt \
      --replace-fail "add_compile_options(\$<\$<COMPILE_LANGUAGE:C,CXX>:-Werror>)" ""
    # Fix hardcoded /etc paths
    find . -name "CMakeLists.txt" -exec \
      sed -i "s|/etc/|$out/etc/|g" {} +
    # Redirect systemd user unit install to our output
    find . -name "CMakeLists.txt" -exec \
      sed -i "s|\''${SYSTEMD_USER_UNIT_DIR}|$out/lib/systemd/user|g" {} +

    # DDEShellConfig.cmake.in exports the install dirs as
    # "@CMAKE_INSTALL_PREFIX@/@DDE_SHELL_*_INSTALL_DIR@", i.e. baked-in absolute
    # paths pointing at *this* store path. Downstream packages (dde-launchpad,
    # dde-tray-loader, ...) then install into dde-shell's read-only output.
    # Re-export them relative so they resolve against each consumer's own prefix.
    sed -i \
      -e 's|@CMAKE_INSTALL_PREFIX@/@DDE_SHELL_PACKAGE_INSTALL_DIR@|''${CMAKE_INSTALL_DATADIR}/dde-shell|' \
      -e 's|@CMAKE_INSTALL_PREFIX@/@DDE_SHELL_PLUGIN_INSTALL_DIR@|''${CMAKE_INSTALL_LIBDIR}/dde-shell|' \
      -e 's|@CMAKE_INSTALL_PREFIX@/@DDE_SHELL_TRANSLATION_INSTALL_DIR@|''${CMAKE_INSTALL_DATADIR}/dde-shell|' \
      misc/DDEShellConfig.cmake.in
  '';

  # No QML2_IMPORT_PATH needed: wrapQtAppsHook already collects every build
  # input's ${qtQmlPrefix} into NIXPKGS_QT6_QML_IMPORT_PATH, which nixpkgs'
  # patched libQt6Qml reads. dde-shell's own QML is found via the compiled-in
  # DDE_SHELL_QML_INSTALL_DIR ($out/lib/qt6/qml) in frame/qmlengine.cpp.
  qtWrapperArgs = [
    # dde-shell discovers third-party shell/tray plugins symlinked into the
    # system profile via environment.pathsToLink (see the NixOS module).
    "--suffix" "DDE_SHELL_PLUGIN_PATH" ":" "/run/current-system/sw/lib/dde-shell"
    "--suffix" "DDE_SHELL_PACKAGE_PATH" ":" "/run/current-system/sw/share/dde-shell"
  ];

  # Ensure systemd user units don't go to systemd's store path
  SYSTEMD_USER_UNIT_DIR = "${placeholder "out"}/lib/systemd/user";

  meta = {
    description = "DDE shell framework (panel, taskbar, applets)";
    homepage = "https://github.com/linuxdeepin/dde-shell";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
