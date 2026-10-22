{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  libical,
  curl,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-calendar";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "calendar";
    rev = "342ffb934dc10733b5367582b0b0dd87f8fed1bb";
    hash = "sha256-NTpjXxZvrel7QNQ5GATT9tOakqDuw+IxgL1enW9XhXI=";
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
    libical
    curl
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Calendar of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/calendar";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-calendar";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
