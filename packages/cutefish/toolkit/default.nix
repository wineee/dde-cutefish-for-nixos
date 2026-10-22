{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  binutils,
  wayland,
  wayland-protocols,
  wayland-scanner,
  libglvnd,
  fontconfig,
  libxkbcommon,
  systemd,
  icu,
  libpng,
  libwebp,
  libtiff,
  libheif,
  libjxl,
  freetype,
  harfbuzz,
  expat,
  zlib,
  libjpeg,
  cutefish-skia,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-toolkit";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "cutefish-toolkit";
    rev = "9e161d0428e0381914e4dfef8572a59904f34391";
    hash = "sha256-t6Zr2hJhMCre9T0zg2YqDx2PxSRCAg8CHmhlmfIAy38=";
  };

  patches = [
    ./toolkit-use-packaged-skia.patch
    # Read the data/config/executable search paths from XDG_* and PATH
    # instead of the hardcoded FHS directories (application menu, MIME
    # database, icon themes, desktop entry TryExec).
    ./toolkit-xdg-paths.patch
  ];

  nativeBuildInputs = [
  cmake
  pkg-config
  gettext # msgfmt, looked up with find_program: without it po/*.po are skipped
  wayland-scanner
  binutils # CMAKE_OBJDUMP, used to read the JPEG XL SONAME
];

  buildInputs = [
    wayland
    wayland-protocols
    libglvnd
    fontconfig
    libxkbcommon
    systemd
    icu
    libpng
    libwebp
    libtiff
    libheif
    libjxl
    # Skia's own dependencies; the static libraries do not carry them.
    freetype
    harfbuzz
    expat
    zlib
    libjpeg
  ];

  cmakeFlags = [ "-DCUTEFISH_SKIA=${cutefish-skia}" ];

  meta = {
    description = "UI toolkit of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/cutefish-toolkit";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
