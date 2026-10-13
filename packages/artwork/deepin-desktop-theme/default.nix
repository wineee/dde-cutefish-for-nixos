{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  qt6Packages,
  dtkcommon,
  dtkcore,
  dtkgui,
  dtkwidget,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-desktop-theme";
  version = "1.1.31";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-desktop-theme";
    rev = finalAttrs.version;
    hash = "sha256-Vc/MkBt0ioa7jPDwJWMkmOSHzH3ZFv+EZcaxCD97BR0=";
  };

  nativeBuildInputs = [
    cmake
    qt6Packages.qttools
  ];

  buildInputs = [
    qt6Packages.qtbase
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
  ];

  dontWrapQtApps = true;

  # Upstream has broken symlinks in bloom-classic themes
  dontCheckForBrokenSymlinks = true;

  cmakeFlags = [ "-DVERSION=${finalAttrs.version}" ];

  meta = {
    description = "Provides a variety of well-designed theme resources";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-theme";
    license = with lib.licenses; [
      gpl3Plus
      cc-by-sa-40
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
