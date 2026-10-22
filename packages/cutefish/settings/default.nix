{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  xkeyboard-config,
  tzdata,
  shadow,
  fontconfig,
  expat,
  icu,
  libxkbcommon,
  libxcrypt,
  systemd,
  pipewire,
  libxcursor,
  libx11,
  xorgproto,
  cutefish-toolkit,
  cutefish-framework,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-settings";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "settings";
    rev = "c0f85ad191468a9dd13fb9afb37a7feebfefddae";
    hash = "sha256-8h/UIQHvOFB8JOa5XvWPtSo2JBU2LKi/sT1PrbvLfjs=";
  };

  # Two hardcoded FHS paths the pages need at runtime.
  postPatch = ''
    substituteInPlace cutefish-settings.desktop \
      --replace-fail "Exec=/usr/bin/" "Exec="
    substituteInPlace src/pages/keyboard/keyboard.cpp \
      --replace-fail '"/usr/share/X11/xkb/rules/evdev.xml"' \
        '"${xkeyboard-config}/share/X11/xkb/rules/evdev.xml"'
    substituteInPlace src/pages/accounts/passwordchanger.h \
      --replace-fail '"/usr/bin/passwd"' '"${shadow}/bin/passwd"'
    substituteInPlace src/pages/accounts/passwordchanger.cpp \
      --replace-fail '"PATH=/usr/sbin:/usr/bin:/sbin:/bin"' \
        '"PATH=${lib.makeBinPath [ shadow ]}"'
    substituteInPlace src/pages/datetime/timezonemap.cpp \
      --replace-fail '"/usr/share/zoneinfo/zone.tab"' \
        '"${tzdata}/share/zoneinfo/zone.tab"'
    # dataDirectories() already covers XDG_DATA_DIRS, the pixmaps fallback
    # only exists on Debian-derived systems.
    substituteInPlace src/pages/cursortheme/cursorthemes.cpp \
      --replace-fail 'list.push_back("/usr/share/pixmaps");' ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    cutefish-framework # CutefishClients, pulled in by the settings modules
    xkeyboard-config # evdev.xml
    tzdata # zone.tab
    shadow # passwd on the accounts page
    fontconfig # the fonts page
    expat # the evdev.xml parser on the keyboard page
    icu
    libxkbcommon # the shortcuts page
    libxcrypt # crypt, the accounts page
    systemd # libsystemd, the bluetooth page
    pipewire # the sound page
    libxcursor # the cursor theme page
    libx11 # Xcursor's own header pulls in Xlib.h
    xorgproto # xproto, pulled in by xcursor.pc
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Settings application of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/settings";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-settings";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
