{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "dtkcommon";
  version = "6.7.50";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-xwg7xkwD+ujU3Dn0XwKdAouP+hyczgqkFWRSVUV7IRw=";
  };

  nativeBuildInputs = [ cmake ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Public project for building DTK Library";
    homepage = "https://github.com/linuxdeepin/dtkcommon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
