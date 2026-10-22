{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  wayland,
  wayland-scanner,
  wayland-protocols,
  systemd,
  fontconfig,
  icu,
  libgbm,
  ffmpeg,
  libva,
  libdrm,
  pipewire,
  polkit,
  tzdata,
  cutefish-toolkit,
  cutefish-framework,
  cutefish-compositor,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-core";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "cutefish-core";
    rev = "4e8e6061d86d349fba093b17e27bea6146d805d2";
    hash = "sha256-SlApZdfpkEnIr2M/UsBn9w/Foj0HONllSXUZJ1U+Nuk=";
  };

  # Everything that assumes an FHS layout. The Debian-only bits are left
  # alone (see locales/ below): those services are simply not enabled by the
  # NixOS module.
  postPatch = ''
    substituteInPlace session/cutefish-wayland-session \
      --replace-fail 'exec /usr/bin/cutefish-session' 'exec ${placeholder "out"}/bin/cutefish-session'
    substituteInPlace session/cutefish-wayland.desktop \
      --replace-fail "TryExec=/usr/bin/cutefish-compositor" "TryExec=${cutefish-compositor}/bin/cutefish-compositor" \
      --replace-fail "Exec=/usr/bin/" "Exec="
    substituteInPlace session/processmanager.cpp \
      --replace-fail '"/usr/bin/cutefish-compositor"' '"${cutefish-compositor}/bin/cutefish-compositor"'
    # Units of a package are collected from $out/lib/systemd.
    substituteInPlace session/CMakeLists.txt \
      --replace-fail "DESTINATION /usr/lib/systemd/user" "DESTINATION lib/systemd/user"
    substituteInPlace session/application.cpp \
      --replace-fail '"/usr/local/share/:/usr/share/"' '"/run/current-system/sw/share"'

    substituteInPlace polkit-agent/authsession.cpp \
      --replace-fail '"/usr/lib/polkit-1/polkit-agent-helper-1"' \
        '"${polkit}/lib/polkit-1/polkit-agent-helper-1"'
    substituteInPlace cutefish-services/appearance/wallpapermanager.cpp \
      --replace-fail '"/usr/share/backgrounds/cutefishos/default.jpg"' \
        '"/run/current-system/sw/share/backgrounds/cutefishos/default.jpg"'
    substituteInPlace cutefish-services/schedule/scheduleutils.cpp \
      --replace-fail '{"/usr/share/zoneinfo/zone1970.tab", "/usr/share/zoneinfo/zone.tab"}' \
        '{"${tzdata}/share/zoneinfo/zone1970.tab", "${tzdata}/share/zoneinfo/zone.tab"}'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
    wayland-scanner
  ];

  buildInputs = [
    cutefish-toolkit
    cutefish-framework # CutefishClients, display components
    wayland
    wayland-protocols
    systemd
    fontconfig
    icu
    libgbm
    ffmpeg
    libva
    libdrm
    pipewire
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  # services.displayManager.sessionPackages: the wayland-sessions entry below.
  passthru.providedSessions = [ "cutefish-wayland" ];

  meta = {
    description = "Session and background services of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/cutefish-core";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
