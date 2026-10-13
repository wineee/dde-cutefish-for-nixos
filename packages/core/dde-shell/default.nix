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
  '';

  # Inject QML paths for DTK modules that install to non-standard lib/qt6/qml.
  qtWrapperArgs = [
    "--prefix" "QML2_IMPORT_PATH" ":" "${dtkdeclarative}/lib/qt6/qml"
    # dde-shell discovers third-party shell/tray plugins symlinked into the
    # system profile via environment.pathsToLink (see the NixOS module).
    "--suffix" "DDE_SHELL_PLUGIN_PATH" ":" "/run/current-system/sw/lib/dde-shell"
    "--suffix" "DDE_SHELL_PACKAGE_PATH" ":" "/run/current-system/sw/share/dde-shell"
  ];

  # Override QtWayland.Compositor QML module in the application directory.
  postInstall = let
    qtwaylandQml = "${qt6Packages.qtwayland}/${qt6Packages.qtbase.qtQmlPrefix}/QtWayland/Compositor";
  in ''
    mkdir -p $out/bin/QtWayland/Compositor/qmlfiles
    cat > $out/bin/QtWayland/Compositor/qmldir <<'QMLDIR'
module QtWayland.Compositor
plugin qwaylandcompositorplugin
classname QWaylandCompositorPlugin
typeinfo WaylandCompositor.qmltypes
depends QtQuick
WaylandCursorItem 6.0 qmlfiles/WaylandCursorItem.qml
WaylandCursorItem 1.0 qmlfiles/WaylandCursorItem.qml
WaylandOutputWindow 6.0 qmlfiles/WaylandOutputWindow.qml
WaylandOutputWindow 1.0 qmlfiles/WaylandOutputWindow.qml
QMLDIR
    ln -s ${qtwaylandQml}/libqwaylandcompositorplugin.so $out/bin/QtWayland/Compositor/
    ln -s ${qtwaylandQml}/WaylandCompositor.qmltypes $out/bin/QtWayland/Compositor/
    for f in ${qtwaylandQml}/qmlfiles/*.qml; do
      ln -s "$f" $out/bin/QtWayland/Compositor/qmlfiles/
    done
  '';

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
