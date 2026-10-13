{
  stdenv,
  lib,
  fetchFromGitHub,
  nixosTests,
  dtkwidget,
  qt6integration,
  qt6platform-plugins,
  cmake,
  qt6Packages,
  pkg-config,
  libsecret,
  lxqt,
  libuchardet,
  libchardet,
  glib,
  icu,
  libxcb-wm,
  libx11,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-terminal";
  version = "6.5.40";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-terminal";
    rev = finalAttrs.version;
    hash = "sha256-F9FKgUuwbatqAjJbzKQ1SmmrxOlN5fSQXrOvMyONEYY=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '/usr/share/deepin-manual/manual-assets/application/' 'share/deepin-manual/manual-assets/application/'
    substituteInPlace 3rdparty/terminalwidget/CMakeLists.txt \
      --replace-fail 'set(CMAKE_INSTALL_PREFIX "/usr")' '# nix: do not override install prefix'
  '';

  cmakeFlags = [ "-DVERSION=${finalAttrs.version}" ];

  nativeBuildInputs = [
    cmake
    qt6Packages.qttools
    pkg-config
    qt6Packages.wrapQtAppsHook
    lxqt.lxqt-build-tools
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtsvg
    qt6Packages.qt5compat
    dtkwidget
    qt6integration
    qt6platform-plugins
    libsecret
    glib
    icu
    libuchardet
    libchardet
    libxcb-wm
    libx11
  ];

  strictDeps = true;

  passthru.tests.test = nixosTests.terminal-emulators.deepin-terminal;

  meta = {
    description = "Terminal emulator with workspace, multiple windows, remote management, quake mode and other features";
    mainProgram = "deepin-terminal";
    homepage = "https://github.com/linuxdeepin/deepin-terminal";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
