{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  fuse3,
  libssh,
  libmtp,
  systemd,
  libarchive,
  libzip,
  samba,
  cutefish-toolkit,
  cutefish-framework,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-filemanager";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "filemanager";
    rev = "a475b515692e2acbf6cdaf2b4c4c16a593095d06";
    hash = "sha256-0+VTdzOGrUsDmfCyfQvpHzOCj8Q1JES2OH7ItbpIOFA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    cutefish-framework # CutefishFiles
    icu
    fuse3
    libssh
    libmtp
    systemd # libudev, removable devices
    libarchive
    libzip
    samba # smbclient
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "File manager of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/filemanager";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-filemanager";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
