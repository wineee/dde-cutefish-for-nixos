{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkwidget,
  dtkgui,
  dtkcore,
  libjpeg,
  djvulibre,
  libgxps,
  cairo,
  glib,
  freetype,
  cups,
  lcms2,
  libchardet,
  openjpeg,
  zlib,
  libpng,
  icu,
}:

stdenv.mkDerivation rec {
  pname = "deepin-reader";
  version = "6.6.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-Yq7HJFbN2KVFZqYOPpNyir71vpcL8mSfVsrTWHHT7L0=";
  };

  postPatch = ''
    # CMake >= 4 applies add_compile_options/add_link_options(-pie) to shared
    # libraries too, breaking the link with `undefined reference to main`.
    # Drop -pie; nix hardens separately.
    substituteInPlace CMakeLists.txt \
      --replace-fail "    -pie" ""

    # Use the Qt6::lrelease imported target instead of a distro hardcoded path
    substituteInPlace cmake/translation-generate.cmake \
      --replace-fail 'set(QT_LRELEASE "/lib/qt''${QT_VERSION_MAJOR}/bin/lrelease")' \
                     'get_target_property(QT_LRELEASE Qt''${QT_VERSION_MAJOR}::lrelease IMPORTED_LOCATION)'

    # Bundled pdfium snapshot relies on a globally force-included <cstdint>
    # (upstream pdfium does this via GN); the CMake port drops it, so inject it
    # for the pdfium target only (all C++).
    sed -i '/^add_library(pdfium STATIC)$/a target_compile_options(pdfium PRIVATE -include cstdint)' \
      3rdparty/deepin-pdfium/src/3rdparty/pdfium/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dtkgui
    dtkcore
    qt6Packages.qtbase
    qt6Packages.qtwebengine
    qt6Packages.qtwebchannel
    qt6Packages.qt5compat
    libjpeg
    djvulibre
    libgxps
    cairo
    glib
    freetype
    cups
    lcms2
    libchardet
    openjpeg
    zlib
    libpng
    icu
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DBUILD_TESTS=OFF"
    "-DOFD_SUPPORT=OFF"
  ];

  meta = with lib; {
    description = "Simple memo software with texts and voice recordings";
    mainProgram = "deepin-reader";
    homepage = "https://github.com/linuxdeepin/deepin-reader";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
