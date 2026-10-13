{
  stdenv,
  lib,
  fetchFromGitHub,
  dtkwidget,
  qt6integration,
  qt6platform-plugins,
  cmake,
  pkg-config,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-shortcut-viewer";
  version = "5.5.6";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-shortcut-viewer";
    rev = finalAttrs.version;
    hash = "sha256-D1ZWPVdKuKjq77V0giWWbIdQef4g3Nvzy0ryktE4qts=";
  };

  postPatch = ''
    # install(TARGETS ... DESTINATION ''${CMAKE_INSTALL_PREFIX}/bin) would
    # install into $out/$out/bin; upstream hardcodes an absolute prefix.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'DESTINATION ''${CMAKE_INSTALL_PREFIX}/bin' 'DESTINATION ''${CMAKE_INSTALL_BINDIR}'
  '';

  nativeBuildInputs = [
    cmake
    qt6Packages.qttools
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    dtkwidget
    qt6integration
    qt6platform-plugins
  ];

  strictDeps = true;

  meta = with lib; {
    description = "Deepin Shortcut Viewer";
    mainProgram = "deepin-shortcut-viewer";
    homepage = "https://github.com/linuxdeepin/deepin-shortcut-viewer";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
