{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "treeland-protocols";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-ZjMIXItqGyqgPVN8EPKPBGDMcjl4Tos/DhibicRJ1A8=";
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
