{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkcore,
  glib,
  libmediainfo,
  libisoburn,
  libsecret,
  udisks2,
  util-linux,
  lucenepp,
  boost,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "util-dfm";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "util-dfm";
    rev = finalAttrs.version;
    hash = "sha256-hvYG3DGfJX0la2mWFnfCFroZ0H3h274NY9aRtSMNckI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
  ];

  buildInputs = [
    qt6Packages.qtbase
    dtkcore
    glib
    libmediainfo
    libisoburn
    libsecret
    udisks2
    util-linux # libmount
    lucenepp
    boost
    openssl
  ];

  dontWrapQtApps = true;

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  meta = {
    description = "File management utility libraries for DDE (dfm6-io, dfm6-mount, dfm6-burn, dfm6-search)";
    homepage = "https://github.com/linuxdeepin/util-dfm";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
