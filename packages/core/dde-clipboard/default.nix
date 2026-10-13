{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  kdePackages,
  dtkcore,
  dtkgui,
  dtkwidget,
  gio-qt,
  dde-shell,
  dde-tray-loader,
  wayland,
  glib,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-clipboard";
  version = "6.1.35";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-clipboard";
    rev = finalAttrs.version;
    hash = "sha256-3lwf7RUQiKn73YZ5DCW+xMGbJbZCtZDXswbcR5p5xBM=";
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
    dtkcore
    dtkgui
    dtkwidget
    gio-qt
    dde-shell
    dde-tray-loader
    wayland
    glib
    gtest
  ];

  cmakeFlags = [
    "-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '/etc/xdg/autostart' "$out/etc/xdg/autostart"
  '';

  meta = {
    description = "DDE optional clipboard manager componment";
    homepage = "https://github.com/linuxdeepin/dde-clipboard";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
