{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkcore,
  dtkcommon,
  glib,
  libsecret,
  systemd,
  libx11,
  libxcb,
  libxcursor,
  libxfixes,
  libcap_ng,
  dde-shell,
  dde-polkit-agent,
  dde-session-shell,
  gnome-keyring,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-session";
  version = "2.0.33";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-session";
    rev = finalAttrs.version;
    hash = "sha256-WpNP9B/T4w1GQMZzmwpcmnoAZNk52rTlc34XeM3rXAo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    dtkcore
    dtkcommon
    glib
    libsecret
    systemd
    libx11
    libxcb
    libxcursor
    libxfixes
    libcap_ng
  ];

  postPatch = ''
    # Fix hardcoded /etc paths across all cmake files
    find . -name "CMakeLists.txt" -exec \
      sed -i "s|/etc/|$out/etc/|g" {} +

    # No window manager yet (treeland is the future compositor). Drop the
    # kwin_x11 line from the X11 session template so the rest of the session
    # graph can still come up.
    sed -i '/ExecStart=\/usr\/bin\/kwin_x11 --replace/d' \
      systemd/dde-session-pre.target.wants/dde-session@x11.service
    sed -i '/kglobalshortcutsrc/d' \
      systemd/dde-session-pre.target.wants/dde-session@x11.service

    # deepin-keyring-whitebox is not packaged; drop its optional branch.
    sed -i '/deepin-keyring-whitebox/,+2d' systemd/dde-keyring.service.in
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
  ];

  # Fix hardcoded /usr/bin and /usr/lib paths in systemd service files
  # and D-Bus service files to use Nix store paths.
  postInstall = ''
    # Fix own binaries
    find $out -name "*.service" -exec sed -i \
      -e "s|/usr/bin/dde-session|$out/bin/dde-session|g" \
      -e "s|/usr/bin/dde-keyring-checker|$out/bin/dde-keyring-checker|g" \
      -e "s|/usr/bin/dde-quick-login|$out/bin/dde-quick-login|g" \
      -e "s|/usr/bin/dde-version-checker|$out/bin/dde-version-checker|g" \
      -e "s|/usr/bin/dde-xsettings-checker|$out/bin/dde-xsettings-checker|g" \
      {} +

    # Fix cross-package references
    find $out -name "*.service" -exec sed -i \
      -e "s|/usr/bin/dde-shell|${dde-shell}/bin/dde-shell|g" \
      -e "s|/usr/bin/dde-lock|${dde-session-shell}/bin/dde-lock|g" \
      -e "s|/usr/lib/polkit-1-dde/dde-polkit-agent|${dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent|g" \
      -e "s|/usr/bin/gnome-keyring-daemon|${gnome-keyring}/bin/gnome-keyring-daemon|g" \
      -e "s|/usr/bin/gdbus|${glib.bin}/bin/gdbus|g" \
      -e "s|/usr/bin/systemctl|/run/current-system/sw/bin/systemctl|g" \
      {} +

    # Fix D-Bus service files
    find $out -name "*.service" -path "*/dbus-1/*" -exec sed -i \
      -e "s|/usr/bin/|$out/bin/|g" \
      -e "s|/usr/lib/|$out/lib/|g" \
      {} +
  '';

  passthru.providedSessions = [ "deepin" ];

  meta = {
    description = "Session manager for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-session";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
