{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "treeland-protocols";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-cWMCw0oY5Fvxv1FtIzfwmqiGOddQT7ILpysldmGo44g=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "Wayland protocol extensions for treeland";
    homepage = "https://github.com/linuxdeepin/treeland-protocols";
    license = with lib.licenses; [
      gpl3Only
      lgpl3Only
      asl20
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
