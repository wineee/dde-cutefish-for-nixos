{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  wayland,
  wayland-scanner,
  wayland-protocols,
  wlr-protocols,
  treeland-protocols,
  pixman,
  pam,
  libinput,
  libxcb,
  xcbutil,
  xcbutilwm,
  xcbutilrenderutil,
  xcbutilkeysyms,
  libxkbcommon,
  libdrm,
  libgbm,
  libglvnd,
  mesa,
  vulkan-loader,
  vulkan-headers,
  glslang,
  libdisplay-info,
  libliftoff,
  hwdata,
  lcms2,
  xwayland,
  seatd,
  systemdLibs,
  libxau,
  libpciaccess,
  libxcrypt,
  mpv-unwrapped,
  dtkcore,
  dtkdeclarative,
  dtksystemsettings,
  ddm,
  dde-session,
  deepin-wallpapers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "treeland";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "treeland";
    rev = finalAttrs.version;
    hash = "sha256-WjSAa1rsj1B4uHV/OfM+G6n5wLgx5RILdHF0GZZxMNo=";
  };

  postPatch = ''
    # Fix hardcoded FHS paths for NixOS. Wallpaper fallback and the various
    # systemd unit ExecStartPre/ExecStart/ExecStop lines that reference
    # /usr/bin or /bin. The /usr/bin/systemctl references are user-session
    # environment calls that NixOS resolves via PATH, but keep them pointing
    # at the current system profile for correctness.
    substituteInPlace src/wallpaper/wallpapermanager.cpp \
      --replace-fail '"/usr/share/wallpapers/deepin/deepin-default.jpg"' '"${deepin-wallpapers}/share/wallpapers/deepin/deepin-default.jpg"'

    # systemd unit ExecStartPre/ExecStart/ExecStop /usr/bin and /bin helpers.
    for f in $(grep -rl -e '/usr/bin/pkill' -e '/usr/bin/systemctl' -e '/usr/bin/llvm-symbolizer' -e 'ExecCondition=/bin/sh' misc/systemd)
    do
      substituteInPlace "$f" \
        --replace '/usr/bin/pkill' '/run/current-system/sw/bin/pkill' \
        --replace '/usr/bin/systemctl' '/run/current-system/sw/bin/systemctl' \
        --replace '/usr/bin/llvm-symbolizer' '/run/current-system/sw/bin/llvm-symbolizer' \
        --replace 'ExecCondition=/bin/sh' 'ExecCondition=/run/current-system/sw/bin/sh'
    done
  '';

  # The single-mode session desktop entries are configured with
  # Exec=${CMAKE_INSTALL_FULL_BINDIR}/dde-session, which resolves to a
  # non-existent $out/bin/dde-session (treeland does not ship dde-session).
  # Point them at the real dde-session binary. Do this after configure_file so
  # the literal $out path is already expanded.
  postInstall = ''
    for f in $out/share/wayland-sessions/treeland.desktop $out/bin/treeland-user-wrapper; do
      substituteInPlace "$f" \
        --replace-fail "$out/bin/dde-session" "${dde-session}/bin/dde-session"
    done
  '';

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
    wayland-scanner
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtwayland
    qt6Packages.qtsvg
    qt6Packages.qtshadertools
    qt6Packages.qtremoteobjects
    qt6Packages.qtwebsockets
    qt6Packages.qthttpserver
    qt6Packages.qtimageformats
    wayland
    wayland-scanner
    wayland-protocols
    wlr-protocols
    treeland-protocols
    pixman
    pam
    libinput
    libxcb
    xcbutil
    xcbutilwm
    xcbutilrenderutil
    xcbutilkeysyms
    libxkbcommon
    libdrm
    libgbm
    libglvnd
    mesa
    vulkan-loader
    vulkan-headers
    glslang
    libdisplay-info
    libliftoff
    hwdata
    lcms2
    xwayland
    seatd
    systemdLibs
    libxau
    libpciaccess
    libxcrypt
    mpv-unwrapped
    dtkcore
    dtkdeclarative
    dtksystemsettings
    ddm
    dde-session
    deepin-wallpapers
  ];

  cmakeFlags = [
    (lib.cmakeFeature "QT_IMPORTS_DIR" "${placeholder "out"}/${qt6Packages.qtbase.qtQmlPrefix}")
    (lib.cmakeFeature "CMAKE_INSTALL_SYSCONFDIR" "${placeholder "out"}/etc")
    (lib.cmakeFeature "SYSTEMD_SYSTEM_UNIT_DIR" "${placeholder "out"}/lib/systemd/system")
    (lib.cmakeFeature "SYSTEMD_SYSUSERS_DIR" "${placeholder "out"}/lib/sysusers.d")
    (lib.cmakeFeature "SYSTEMD_TMPFILES_DIR" "${placeholder "out"}/lib/tmpfiles.d")
    (lib.cmakeFeature "DBUS_CONFIG_DIR" "${placeholder "out"}/share/dbus-1/system.d")
    (lib.cmakeBool "WITH_SUBMODULE_WAYLIB" true)
    (lib.cmakeBool "TREELAND_INSTALL_DEV" false)
    # Do not build the protocol test binaries, only the compositor and tools.
    (lib.cmakeBool "BUILD_TREELAND_PROTOCOL_TESTS" false)
  ];

  env.PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  # RPATH of binary /nix/store/.../bin/... contains a forbidden reference to /build/
  noAuditTmpdir = true;

  passthru.providedSessions = [ "treeland" "treeland-user" ];

  meta = with lib; {
    description = "Wayland compositor based on wlroots and QtQuick";
    homepage = "https://github.com/linuxdeepin/treeland";
    license = with licenses; [
      gpl3Only
      lgpl3Only
      asl20
    ];
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
