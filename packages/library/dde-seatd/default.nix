{
  fetchFromGitHub,
  lib,
  meson,
  ninja,
  pkg-config,
  scdoc,
  stdenv,
  systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-seatd";
  version = "0.9.3-3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-seatd";
    rev = finalAttrs.version;
    hash = "sha256-wMRF07Eh7QTfedfGmSY6+U6eJiCwxp/zaX6ltLilvds=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "man"
  ];

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    systemdLibs
  ];

  postPatch = ''
    # The bundled systemd unit hardcodes /usr/sbin/dde-seatd; point it at the
    # actual Nix store path (sbindir is a symlink to bindir in nixpkgs).
    substituteInPlace contrib/systemd/dde-seatd.service \
      --replace-fail '/usr/sbin/dde-seatd' "${placeholder "bin"}/bin/dde-seatd"
  '';

  # dde-seatd ships a renamed libseat-compatible stack (libdde-seat.so with a
  # libseat.h header) alongside the dde-seatd daemon. The library still links
  # libsystemd for its logind backend.
  mesonFlags = [
    "-Dlibseat-logind=systemd"
    "-Dlibseat-builtin=disabled"
    "-Dlibseat-seatd=enabled"
    "-Dserver=enabled"
    "-Dexamples=disabled"
  ];

  meta = {
    description = "DDE seat management daemon and renamed libseat-compatible stack";
    homepage = "https://github.com/linuxdeepin/dde-seatd";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dde-seatd";
    maintainers = with lib.maintainers; [ wineee ];
  };
})
