{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  poppler,
  libzip,
  pugixml,
  freetype,
  libxml2,
  util-linux,
  tinyxml-2,
  file,
  minizip,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "docparser";
  version = "1.0.26";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "docparser";
    rev = finalAttrs.version;
    hash = "sha256-5OlIspH7F/YigQvAaPVPSQElDprrmCjId7QSD/A/wxo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    poppler
    libzip
    pugixml
    freetype
    libxml2
    util-linux # libuuid
    tinyxml-2
    file # libmagic
    minizip
    zlib
  ];

  # Fix pkgconfig double-prefix issue (NixOS uses absolute install dirs)
  patches = [
    ./fix-pc-double-prefix.patch
  ];

  postPatch = ''
    # CMake >= 4 errors when add_link_options(-pie) is applied to a shared
    # library (undefined reference to main). Drop it; nix hardens separately.
    substituteInPlace CMakeLists.txt \
      --replace-fail '-z noexecstack -pie -fPIC' '-z noexecstack -fPIC'
  '';

  meta = {
    description = "Document content analysis library for full-text search";
    homepage = "https://github.com/linuxdeepin/docparser";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
