{
  stdenv,
  lib,
  fetchFromGitHub,
  dtkwidget,
  dtkcore,
  qt6integration,
  qt6platform-plugins,
  dde-shell,
  pkg-config,
  cmake,
  qt6Packages,
  kdePackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-polkit-agent";
  version = "6.0.24";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-LfqrbbgiHQpWqWjQAfIwN6cnaHrl+mQCX6/GZR0prYY=";
  };

  postPatch = ''
    substituteInPlace pluginmanager.cpp \
      --replace-fail "/usr/lib/polkit-1-dde/plugins/" "$out/lib/polkit-1-dde/plugins/"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dtkcore
    qt6integration
    qt6platform-plugins
    dde-shell
    qt6Packages.qtbase
    kdePackages.polkit-qt-1
  ];

  postFixup = ''
    # The binary is installed to lib/polkit-1-dde, outside the dirs the
    # wrapQtAppsHook auto-wraps, so wrap it manually.
    wrapQtApp $out/lib/polkit-1-dde/dde-polkit-agent
  '';

  strictDeps = true;

  meta = with lib; {
    description = "PolicyKit agent for Deepin Desktop Environment";
    mainProgram = "dde-polkit-agent";
    homepage = "https://github.com/linuxdeepin/dde-polkit-agent";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
