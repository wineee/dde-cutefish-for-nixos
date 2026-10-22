{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  librsvg,
  wayland,
  wayland-scanner,
  wayland-protocols,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-qt-plugins";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "qt-plugins";
    rev = "7e1a132d26aae471832179f765c7c5d28d62bc4a";
    hash = "sha256-NymabMQZIYPYcVURo8NiROIQE1i8f3Q89X96tYGTv3w=";
  };

  patches = [
    # Qt 6.11 removed QWindowSystemInterface::handleThemeChange(QWindow*).
    ./qt611-handle-theme-change.patch
    # Install the plugins into our own output instead of the directory
    # qtpaths6 reports, which lives inside qtbase and is read-only.
    ./qtplugins-install-to-output.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qttools
    librsvg
    wayland
    wayland-protocols
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DCUTEFISH_QT_PLUGIN_DIR=${placeholder "out"}/${qt6Packages.qtbase.qtPluginPrefix}"
  ];

  # Qt plugins only, nothing to wrap.
  dontWrapQtApps = true;

  meta = {
    description = "Qt integration plugins for the Cutefish desktop";
    homepage = "https://github.com/cutefishos/qt-plugins";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
