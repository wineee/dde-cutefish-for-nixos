{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  mpv,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-video-player";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "video-player";
    rev = "86f2eab74dadfd0482f457122547e0684bca3f23";
    hash = "sha256-3mPfyqau/0JExgwKToZ6qHJgDlXLNb2BushKxgzVfO0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
    mpv
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Video player of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/video-player";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-video-player";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
