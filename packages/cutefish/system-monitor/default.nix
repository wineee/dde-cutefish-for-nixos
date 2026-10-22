{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  hwdata,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-system-monitor";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "system-monitor";
    rev = "0ddafa412a7e2959a652846f80e867dc253cff26";
    hash = "sha256-ySU7vWdAgvhRkTItQvFh/Buw8HjmQvPqL9Yr1D4GMmA=";
  };

  # GPU names come from the PCI ID database, which only exists in FHS layouts
  # on Debian-derived systems.
  postPatch = ''
    substituteInPlace src/gpureader.cpp \
      --replace-fail '{"/usr/share/misc/pci.ids", "/usr/share/hwdata/pci.ids"}' \
        '{"${hwdata}/share/hwdata/pci.ids", "/usr/share/hwdata/pci.ids"}'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
    hwdata
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "System monitor of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/system-monitor";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-system-monitor";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
