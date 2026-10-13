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
  dde-application-manager,
  dde-polkit-agent,
  dde-session-shell,
  gnome-keyring,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-session";
  version = "2.0.34";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-session";
    rev = finalAttrs.version;
    hash = "sha256-faXUkJTA4bfA+oIVE/kaiPbll+nEbJMUREi8/K493fI=";
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
    dde-application-manager
  ];

  postPatch = ''
    # Absolute DESTINATION ignores CMAKE_INSTALL_SYSCONFDIR.
    substituteInPlace misc/CMakeLists.txt \
      --replace-fail "DESTINATION /etc/X11/Xsession.d/" "DESTINATION $out/etc/X11/Xsession.d/" \
      --replace-fail "DESTINATION /etc/profile.d" "DESTINATION $out/etc/profile.d"
    substituteInPlace tools/dde-oom-score-adj/CMakeLists.txt \
      --replace-fail "DESTINATION /etc/xdg/autostart/" "DESTINATION $out/etc/xdg/autostart/"

    # Exec paths compiled into the binaries.
    substituteInPlace src/dde-session/impl/sessionmanager.cpp \
      --replace-fail '"/usr/bin/dde-lock"' '"${dde-session-shell}/bin/dde-lock"' \
      --replace-fail '"/usr/libexec/deepin/dde-lock"' '"${dde-session-shell}/libexec/deepin/dde-lock"' \
      --replace-fail '"/usr/bin/dde-am"' '"${dde-application-manager}/bin/dde-am"' \
      --replace-fail '"/usr/libexec/dde-session-ctl"' '"$out/libexec/dde-session-ctl"' \
      --replace-fail '"/usr/lib/deepin-daemon/langselector"' \
                     '"/run/current-system/sw/lib/deepin-daemon/langselector"' \
      --replace-fail '"/usr/bin/systemd-detect-virt"' '"${systemd}/bin/systemd-detect-virt"'

    substituteInPlace tools/dde-quick-login/lockprocessmanager.cpp \
      --replace-fail '"/usr/bin/dde-lock"' '"${dde-session-shell}/bin/dde-lock"'
    substituteInPlace tools/dde-version-checker/main.cpp \
      --replace-fail '"/usr/lib/deepin-daemon/dde-welcome"' \
                     '"/run/current-system/sw/lib/deepin-daemon/dde-welcome"'

    # Shell / desktop files, resolved at runtime.
    substituteInPlace misc/Xsession.d/00deepin-dde-env \
      --replace-fail '"/usr/bin/dde-session"' '"$out/bin/dde-session"'
    substituteInPlace misc/Xsession.d/97deepin-keyring-wb \
      --replace-fail "/usr/lib/systemd/user/dde-keyring.service" \
                     "$out/share/systemd/user/dde-keyring.service"
    substituteInPlace tools/dde-oom-score-adj/dde-oom-score-adj.desktop \
      --replace-fail "/usr/bin/dde-oom-score-adj" "$out/bin/dde-oom-score-adj"
    substituteInPlace misc/dde-session-loader-wrapper.in \
      --replace-fail "PATH=/usr/sbin:/usr/bin:/sbin:/bin" "PATH=/run/current-system/sw/bin"

    # D-Bus / systemd units: own binaries and cross-package references.
    substituteInPlace dbus/org.deepin.dde.Session1.service \
      --replace-fail "/usr/bin/dde-session" "$out/bin/dde-session"
    substituteInPlace systemd/dde-session-manager.service.in \
      --replace-fail "/usr/bin/gdbus" "${glib.bin}/bin/gdbus"
    substituteInPlace systemd/dde-keyring.service.in \
      --replace-fail "/usr/bin/gnome-keyring-daemon" "${gnome-keyring}/bin/gnome-keyring-daemon"
    substituteInPlace systemd/dde-session-core.target.wants/dde-shell@DDE.service \
      --replace-fail "/usr/bin/dde-shell" "${dde-shell}/bin/dde-shell" \
      --replace-fail "/usr/bin/systemctl" "/run/current-system/sw/bin/systemctl"
    substituteInPlace systemd/dde-session-core.target.wants/dde-shell-plugin@org.deepin.ds.desktop.service \
      --replace-fail "/usr/bin/dde-shell" "${dde-shell}/bin/dde-shell"
    substituteInPlace systemd/dde-session-initialized.target.wants/dde-lock.service \
      --replace-fail "/usr/bin/dde-lock" "${dde-session-shell}/bin/dde-lock"
    substituteInPlace systemd/dde-session-initialized.target.wants/dde-polkit-agent.service \
      --replace-fail "/usr/lib/polkit-1-dde/dde-polkit-agent" \
                     "${dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent"
    substituteInPlace systemd/dde-session-pre.target.wants/dde-quick-login@x11.service \
      --replace-fail "/usr/bin/dde-quick-login" "$out/bin/dde-quick-login"
    substituteInPlace tools/dde-keyring-checker/dde-keyring-checker.service \
      --replace-fail "/usr/bin/dde-keyring-checker" "$out/bin/dde-keyring-checker"
    substituteInPlace tools/dde-version-checker/dde-version-checker.service \
      tools/dde-version-checker/dde-version-checker@quick-login.service \
      --replace-fail "/usr/bin/dde-version-checker" "$out/bin/dde-version-checker"
    substituteInPlace tools/dde-xsettings-checker/dde-xsettings-checker.service \
      --replace-fail "/usr/bin/dde-xsettings-checker" "$out/bin/dde-xsettings-checker"

    # No X11 window manager (treeland is the compositor): the X11 session unit
    # is inert on Wayland anyway (ConditionEnvironment=XDG_SESSION_TYPE=%I).
    substituteInPlace systemd/dde-session-pre.target.wants/dde-session@x11.service \
      --replace-fail "ExecStart=/usr/bin/kwin_x11 --replace" "# kwin_x11: not packaged"
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
  ];

  passthru.providedSessions = [ "deepin" ];

  meta = {
    description = "Session manager for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-session";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
