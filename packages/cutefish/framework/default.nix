{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  libpng,
  pipewire,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-framework";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "cutefish-framework";
    rev = "c138da60f59f906b91def406168460ce3cedd1c2";
    hash = "sha256-iZj+sQQ2JbmyYyUfsIwUFTHPNr2S6jLmxUgZURpCS1k=";
  };

  # Not picky about a libspa version, just about spa/pod/parser.h having pulled
  # in iter.h: since PipeWire 1.x it no longer does, and spa_pod_find_prop()
  # lives in iter.h.
  patches = [ ./framework-include-spa-iter.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu # files: icu-uc
    libpng # files: thumbnails
    pipewire # audio client: libpipewire-0.3 >= 0.3.65, libspa-0.2
  ];

  # include(CTest) turns BUILD_TESTING on, and most of these talk to system
  # services (UPower, NetworkManager, BlueZ, PipeWire) that do not exist in
  # the build sandbox.
  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Clients of the system services used by the Cutefish desktop";
    homepage = "https://github.com/cutefishos/cutefish-framework";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
