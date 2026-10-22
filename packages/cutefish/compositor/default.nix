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
  seatd,
  pipewire, # pulled in through cutefish-framework's audio client
  libdrm,
  mesa,
  libglvnd,
  libgbm,
  libxkbcommon,
  libinput,
  systemd,
  harfbuzz,
  freetype,
  fontconfig,
  icu,
  libxcb,
  pam,
  xwayland,
  libffi,
  cutefish-toolkit,
  cutefish-framework,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-compositor";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "cutefish-compositor";
    rev = "0c2787486fc94bcba7af1f68cc9b40832a53a559";
    hash = "sha256-NvjlUtq6rdH9EHZc5+O6fk8ZC+DQh2par+5hc1LB7N4=";
  };

  patches = [
    ./compositor-missing-cstdint.patch
    # cutefish-services / cutefish-polkit-agent (both cutefish-core, which
    # depends on the compositor) are looked up on PATH instead of being
    # compiled in.
    ./compositor-nix-paths.patch
  ];

  # Everything else with an FHS path. The session directories and the default
  # wallpaper are what the system profile provides -- the wallpapers are
  # unfree, so core/compositor must not depend on them directly.
  postPatch = ''
    substituteInPlace src/auth/login_sessions.cpp \
      --replace-fail 'return {"/usr/local/share/wayland-sessions", "/usr/share/wayland-sessions"};' \
        'return {"/run/current-system/sw/share/wayland-sessions"};'
    substituteInPlace src/shell/wallpaper/wallpaper.cpp src/session/secure_container.cpp \
      --replace-fail '"/usr/share/backgrounds/cutefishos/default.jpg"' \
        '"/run/current-system/sw/share/backgrounds/cutefishos/default.jpg"'
    substituteInPlace src/xwayland/xwayland_server.h \
      --replace-fail '"/usr/bin/Xwayland"' '"${xwayland}/bin/Xwayland"'
    # dataDirectories() already covers XDG_DATA_DIRS; the pixmaps fallback only
    # exists on Debian-derived systems.
    substituteInPlace src/cursor/theme.cpp \
      --replace-fail '        paths.push_back("/usr/share/pixmaps");' ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    cutefish-framework
    wayland
    wayland-protocols
    seatd # libseat
    pipewire
    libdrm
    libgbm # gbm
    mesa
    libglvnd # egl, glesv2
    libxkbcommon
    libinput
    systemd # libudev
    harfbuzz
    freetype
    fontconfig
    icu
    libxcb # xcb xcb-composite xcb-xfixes xcb-shape xcb-sync
    pam
    xwayland # /usr/bin/Xwayland
    libffi # wayland-server.pc lists libffi in Requires.private
  ];

  # include(CTest) turns BUILD_TESTING on; the tests drive real surfaces and
  # need a running compositor, not just the sandbox.
  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Wayland compositor of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/cutefish-compositor";
    license = with lib.licenses; [ bsd3 mit asl20 ];
    mainProgram = "cutefish-compositor";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
