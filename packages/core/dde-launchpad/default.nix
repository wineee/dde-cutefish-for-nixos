{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  glib,
  systemd,
  appstream,
  kdePackages,
  dtkcommon,
  dtkcore,
  dtkgui,
  dtkdeclarative,
  dde-shell,
  dde-application-manager,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-launchpad";
  version = "2.0.48";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-launchpad";
    rev = finalAttrs.version;
    hash = "sha256-/JqgwwbwuMpTFcxCV8QU0p1Kc3iaQmIXYR+mIZWxsRM=";
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
    qt6Packages.qtsvg
    qt6Packages.qtwayland
    qt6Packages.qt5compat
    glib
    systemd
    appstream
    kdePackages.appstream-qt
    dtkcommon
    dtkcore
    dtkgui
    dtkdeclarative
    dde-shell
    dde-application-manager
  ];

  # After cmake configure, fix the generated install scripts to redirect
  # dde-shell paths and Qt QML module paths to $out
  postConfigure = ''
    find . -name "cmake_install.cmake" -exec sed -i \
      -e "s|${dde-shell}/share/dde-shell|$out/share/dde-shell|g" \
      -e "s|${dde-shell}/lib/dde-shell|$out/lib/dde-shell|g" \
      -e "s|${qt6Packages.qtbase}/${qt6Packages.qtbase.qtQmlPrefix}|$out/lib/qt6/qml|g" {} +
  '';

  # Create on-disk qmldir files for QML module discovery.
  # dde-launchpad's 3 QML modules (org.deepin.launchpad, .models, .windowed)
  # are embedded in launchpadcommon.so as Qt resources via STATIC linking.
  # The QML engine needs on-disk qmldir to discover them; "prefer" redirects
  # to the resource-embedded content at :/qt/qml/...
  postInstall = ''
    for mod in \
      "org/deepin/launchpad" \
      "org/deepin/launchpad/models" \
      "org/deepin/launchpad/windowed"; do
      mkdir -p "$out/lib/qt6/qml/$mod"
      uri=$(echo "$mod" | tr '/' '.')
      printf 'module %s\nprefer :/qt/qml/%s/\n' "$uri" "$mod" \
        > "$out/lib/qt6/qml/$mod/qmldir"
    done
  '';

  cmakeFlags = [
    "-DBUILD_TEST=OFF"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
  ];

  meta = {
    description = "Application launcher for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-launchpad";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
