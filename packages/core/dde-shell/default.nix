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
    # shell/CMakeLists.txt falls back to pkg_get_variable(systemduserunitdir)
    # when this is unset, i.e. systemd's own read-only store path. It guards
    # with `if (NOT DEFINED ...)`, so a -D flag is the intended override (an
    # environment variable is not: CMake does not import env vars as vars).
    "-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
  ];

  postPatch = ''
    # Upstream compiles with -Werror; Qt 6.9 deprecates QSortFilterProxyModel::
    # invalidateFilter() which upstream still calls, so drop -Werror to keep
    # deprecated-declarations warnings non-fatal.
    substituteInPlace CMakeLists.txt \
      --replace-fail "add_compile_options(\$<\$<COMPILE_LANGUAGE:C,CXX>:-Werror>)" ""

    # DDEShellConfig.cmake.in bakes this store path into the exported
    # @DDE_SHELL_*_INSTALL_DIR@ values that a consumer's ds_install_package()
    # installs into, i.e. into dde-shell's read-only output. Drop only the
    # "@CMAKE_INSTALL_PREFIX@/" prefix: upstream's value is already relative
    # ("share/dde-shell", "lib/dde-shell") and a relative install(DESTINATION)
    # resolves against each consumer's own CMAKE_INSTALL_PREFIX.
    substituteInPlace misc/DDEShellConfig.cmake.in \
      --replace-fail '@CMAKE_INSTALL_PREFIX@/@DDE_SHELL_PACKAGE_INSTALL_DIR@' \
                     '@DDE_SHELL_PACKAGE_INSTALL_DIR@' \
      --replace-fail '@CMAKE_INSTALL_PREFIX@/@DDE_SHELL_PLUGIN_INSTALL_DIR@' \
                     '@DDE_SHELL_PLUGIN_INSTALL_DIR@' \
      --replace-fail '@CMAKE_INSTALL_PREFIX@/@DDE_SHELL_TRANSLATION_INSTALL_DIR@' \
                     '@DDE_SHELL_TRANSLATION_INSTALL_DIR@'
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

  meta = {
    description = "DDE shell framework (panel, taskbar, applets)";
    homepage = "https://github.com/linuxdeepin/dde-shell";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
