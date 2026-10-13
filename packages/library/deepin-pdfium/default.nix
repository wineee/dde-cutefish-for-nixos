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

  # nixpkgs passes CMAKE_INSTALL_LIBDIR/INCLUDEDIR as absolute paths, so the
  # upstream `\${prefix}/@CMAKE_INSTALL_*@` form double-prefixes the .pc.
  # Use the _FULL_ variants (already absolute) instead.
  patches = [
    ./fix-pc-double-prefix.patch
  ];

  meta = {
    description = "PDF rendering library based on PDFium for Deepin";
    homepage = "https://github.com/linuxdeepin/deepin-pdfium";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
