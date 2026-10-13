{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkwidget,
  dtkgui,
  udisks2-qt6,
  libx11,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-device-formatter";
  version = "1.5.11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-device-formatter";
    rev = finalAttrs.version;
    hash = "sha256-N2teUYKtwKsj58eFXAtHfw4kqR4+x/Dbdbx0FSvx2Vs=";
  };

  postPatch = ''
    substituteInPlace dde-device-formatter.desktop \
      --replace-fail "/usr/bin/dde-device-formatter" "$out/bin/dde-device-formatter"

    # Qt6::GuiPrivate is linked but not listed in find_package COMPONENTS.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(QT_COMPONENTS Core Gui Widgets Concurrent Network DBus LinguistTools)' \
                     'set(QT_COMPONENTS Core Gui Widgets Concurrent Network DBus LinguistTools GuiPrivate)'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dtkgui
    udisks2-qt6
    qt6Packages.qtbase
    libx11
  ];

  cmakeFlags = [ "-DVERSION=${finalAttrs.version}" ];

  meta = {
    description = "Simple graphical interface for creating file system in a block device";
    mainProgram = "dde-device-formatter";
    homepage = "https://github.com/linuxdeepin/dde-device-formatter";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
