{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  libchardet,
  lcms2,
  freetype,
  openjpeg,
  zlib,
  libpng,
  libjpeg,
  icu,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-pdfium";
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-pdfium";
    rev = finalAttrs.version;
    hash = "sha256-D1jjNdjJ+VqIIB5KaNq1fsPQqYTpXHs4HPfqKeluvOw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    qt6Packages.qtbase
    libchardet
    lcms2
    freetype
    openjpeg
    zlib
    libpng
    libjpeg
    icu
  ];

  dontWrapQtApps = true;

  # Fix pkgconfig double-prefix issue (NixOS uses absolute install dirs)
  postInstall = ''
    find $out/lib/pkgconfig -name "*.pc" -exec sed -i "s|''${prefix}/|/|g" {} +
  '';

  meta = {
    description = "PDF rendering library based on PDFium for Deepin";
    homepage = "https://github.com/linuxdeepin/deepin-pdfium";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
