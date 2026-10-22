{
  stdenv,
  lib,
  fetchFromGitHub,
  gn,
  ninja,
  python3,
  clang,
  expat,
  fontconfig,
  freetype,
  harfbuzzFull,
  icu,
  libpng,
  libjpeg,
  zlib,
  libglvnd,
  libx11,
}:

let
  # GN's name for the host CPU.
  targetCpu = {
    x86_64 = "x64";
    i686 = "x86";
    aarch64 = "arm64";
  }.${stdenv.hostPlatform.parsed.cpu.name};
in

# Skia for cutefish-toolkit, pinned to the revision upstream pins
# (scripts/fetch-skia.sh: chrome/m156). nixpkgs' own skia cannot be used:
# it is a shared build (is_component_build=true) of a different milestone
# without the GL backend, and it ships none of the module libraries
# (svg/skparagraph/skshaper/skunicode/...) the toolkit links.
#
# The headers are installed keeping the layout of the source tree
# ($out/skia/include, $out/skia/modules, $out/skia/src) because the toolkit
# includes them as "include/core/SkCanvas.h" relative to the source root.
stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-skia";
  version = "156-unstable-2026-10-19";

  src = fetchFromGitHub {
    owner = "google";
    repo = "skia";
    rev = "95ee33d7ec7791ab9c071675710a14fe6408ae4f";
    # Unpacked NAR hash. Getting it costs a >500 MB download, so do not
    # regenerate it casually: `nix build .#cutefish-skia` and read `got:`.
    hash = "sha256-ou4cLjDBhKrL7yUJX/4el/HTDDWcmpL9ZGsdmHjX3I4=";
  };

  nativeBuildInputs = [
    gn
    ninja
    python3
    clang
  ];

  buildInputs = [
    expat
    fontconfig
    freetype
    harfbuzzFull
    icu
    libpng
    libjpeg
    zlib
    libglvnd
    libx11
  ];

  # GN reads args.gn itself; feed it the flags cutefish-toolkit's
  # cmake/Skia.cmake uses, plus the system libraries and a fixed toolchain.
  # GN args must not contain spaces around '=' when passed like this.
  postPatch = ''
    mkdir -p out
    cat > out/args.gn <<'EOF'
    is_official_build = true
    is_debug = false
    target_cpu = "${targetCpu}"
    cc = "${clang}/bin/clang"
    cxx = "${clang}/bin/clang++"
    ar = "${stdenv.cc.targetPrefix}ar"
    # Classes derived from Skia types need its typeinfo; Skia passes AVX
    # vectors between functions built for AVX on purpose.
    extra_cflags_cc = [ "-frtti" ]
    extra_cflags = [ "-Wno-psabi", "-I${harfbuzzFull.dev}/include/harfbuzz" ]
    skia_use_system_expat = true
    skia_use_system_freetype2 = true
    skia_use_system_harfbuzz = true
    skia_use_system_icu = true
    skia_use_system_libjpeg_turbo = true
    skia_use_system_libpng = true
    skia_use_system_zlib = true
    skia_use_partition_alloc = false
    skia_use_gl = true
    skia_use_egl = true
    skia_use_vulkan = false
    skia_enable_graphite = false
    skia_enable_pdf = false
    skia_enable_skottie = false
    skia_enable_svg = true
    skia_use_wuffs = false
    skia_use_dng_sdk = false
    skia_use_piex = false
    skia_use_libwebp_decode = false
    skia_use_libwebp_encode = false
    skia_use_expat = true
    skia_use_perfetto = false
    skia_enable_fontmgr_custom_directory = false
    skia_enable_fontmgr_custom_embedded = false
    skia_enable_fontmgr_custom_empty = false
    EOF
  '';

  configurePhase = ''
    runHook preConfigure
    gn gen out --root=.
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    ninja -C out \
      skia modules/svg modules/skresources modules/skparagraph modules/skshaper \
      modules/skunicode
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/skia
    cp out/*.a $out/lib
    find include modules src -name '*.h' -exec install -Dm644 {} $out/skia/{} \;
    runHook postInstall
  '';

  # Nothing links this one directly; it is consumed as static libraries plus
  # headers.
  dontFixup = true;

  meta = {
    description = "Skia pinned to the revision cutefish-toolkit builds against";
    homepage = "https://github.com/google/skia";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
