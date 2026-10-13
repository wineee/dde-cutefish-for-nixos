{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  kdePackages,
  wayland,
  wayland-scanner,
  pam,
  systemdLibs,
  libxau,
  treeland-protocols,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ddm";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "ddm";
    rev = finalAttrs.version;
    hash = "sha256-k+TsNHcYj/AeebrSX/FrIymE6eJRBjGDkz21ophKngM=";
  };

  postPatch = ''
    # Fix hardcoded FHS paths for NixOS. HALT_COMMAND/REBOOT_COMMAND are plain
    # set() variables in the top-level CMakeLists.txt, the rest live in
    # Configuration.h defaults. Config overrides remain possible at runtime.
    substituteInPlace CMakeLists.txt \
      --replace-fail '"/usr/bin/systemctl poweroff"' '"/run/current-system/sw/bin/systemctl poweroff"' \
      --replace-fail '"/usr/bin/systemctl reboot"' '"/run/current-system/sw/bin/systemctl reboot"'

    substituteInPlace src/common/Configuration.h \
      --replace-fail '"/usr/bin/X"' '"/run/current-system/sw/bin/X"' \
      --replace-fail '"/usr/local/share/xsessions"' '"/run/current-system/sw/share/xsessions"' \
      --replace-fail '"/usr/share/xsessions"' '"/run/current-system/sw/share/xsessions"' \
      --replace-fail '"/usr/local/share/wayland-sessions"' '"/run/current-system/sw/share/wayland-sessions"' \
      --replace-fail '"/usr/share/wayland-sessions"' '"/run/current-system/sw/share/wayland-sessions"' \
      --replace-fail '"/usr/local/bin:/usr/bin:/bin"' '"/run/current-system/sw/bin"'
  '';

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
    wayland-scanner
  ];

  buildInputs = [
    qt6Packages.qtbase
    pam
    systemdLibs
    libxau
    wayland
    treeland-protocols
  ];

  cmakeFlags = [
    # Provide UID_MIN/UID_MAX so the build does not try to read
    # /etc/login.defs (unavailable in the sandbox). Values match NixOS.
    "-DUID_MIN=1000"
    "-DUID_MAX=29999"
    "-DDDM_INITIAL_VT=7"
    # STATE_DIR/LOG_FILE default to ${CMAKE_INSTALL_FULL_LOCALSTATEDIR}/...,
    # which in Nix resolves to <store>/var/... (read-only). Pin them to the
    # FHS locations the NixOS module provisions (systemd.tmpfiles + users).
    "-DSTATE_DIR=/var/lib/ddm"
    "-DLOG_FILE=/var/log/ddm.log"
    # Let the NixOS module generate configuration at runtime instead of
    # baking the store path into Constants.h (upstream ~/ddm/nix precedent).
    "-DCONFIG_FILE=/etc/ddm.conf"
    "-DCONFIG_DIR=/etc/ddm.conf.d"
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
    "-DSYSTEMD_SYSTEM_UNIT_DIR=${placeholder "out"}/lib/systemd/system"
    "-DSYSTEMD_SYSUSERS_DIR=${placeholder "out"}/lib/sysusers.d"
    "-DSYSTEMD_TMPFILES_DIR=${placeholder "out"}/lib/tmpfiles.d"
    "-DDBUS_CONFIG_DIR=${placeholder "out"}/share/dbus-1/system.d"
  ];

  meta = with lib; {
    description = "DDM is a fork of SDDM, a modern display manager for Deepin";
    homepage = "https://github.com/linuxdeepin/ddm";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    mainProgram = "ddm";
    maintainers = with lib.maintainers; [ wineee ];
  };
})
