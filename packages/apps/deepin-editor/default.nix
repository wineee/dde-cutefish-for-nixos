{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  dtkwidget,
  qt6integration,
  qt6platform-plugins,
  kdePackages,
  libchardet,
  libuchardet,
  libiconv,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-editor";
  version = "6.7.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-editor";
    rev = finalAttrs.version;
    hash = "sha256-icD7kUmHrtbxDUnJWkTYZqpZhHsoRd7B/ftuFyA+tgg=";
  };

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail '/usr/share/deepin-editor/themes/deepin.theme' \
                     '$out/share/deepin-editor/themes/deepin.theme'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qt6integration
    qt6platform-plugins
    qt6Packages.qtbase
    qt6Packages.qtsvg
    qt6Packages.qtwebengine
    qt6Packages.qtwebchannel
    qt6Packages.qt5compat
    kdePackages.kcodecs
    kdePackages.syntax-highlighting
    libchardet
    libuchardet
    libiconv
  ];

  strictDeps = true;

  cmakeFlags = [
    "-DVERSION=${finalAttrs.version}"
    "-DBUILD_TESTS=OFF"
  ];

  # Fix build with icu4c: "error: parameter declared 'auto'"
  env.NIX_CFLAGS_COMPILE = toString [ "--std=c++17" ];

  meta = {
    description = "Desktop text editor that supports common text editing features";
    mainProgram = "deepin-editor";
    homepage = "https://github.com/linuxdeepin/deepin-editor";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
