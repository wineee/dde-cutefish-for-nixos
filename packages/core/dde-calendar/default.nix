{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkwidget,
  qt6integration,
  qt6platform-plugins,
  libical,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-calendar";
  version = "6.6.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-I4e2XVd7GE9bt4LO7p+63+M5SDqeddfqRSCvFjZfe8c=";
  };

  postPatch = ''
    # The service/systemd/autostart files invoke dbus-send via a hardcoded
    # /bin/bash shebang/Exec line; point them at the Nix-provided shell.
    for file in $(grep -rl "/bin/bash" src misc); do
      substituteInPlace $file --replace-fail "/bin/bash" "${runtimeShell}"
    done

    # calendar-service gates its D-Bus API on a client whitelist that is only
    # compiled in when CALENDAR_SERVICE_AUTO_EXIT is set (i.e. every non-Debug
    # build). It compares the caller's /proc/<pid>/status Name against
    # "dde-calendar" with exact equality. On NixOS the client is the wrapped
    # binary, so the name is ".dde-calendar-wrapped" truncated to 15 chars and
    # never matches -- the service then answers every request with
    # org.freedesktop.DBus.Error.AccessDenied. Accept any name containing
    # "dde-calendar" so the wrapped client is allowed through.
    substituteInPlace src/calendar-service/src/dbusservice/dservicebase.cpp \
      --replace-fail 'qCDebug(ServiceLogger) << "Client" << clientName << "not found in whitelist, denying access";' \
                     'if (clientName.contains(QStringLiteral("dde-calendar"))) {
        qCDebug(ServiceLogger) << "Client" << clientName << "allowed by dde-calendar name match";
        return true;
    }
    qCDebug(ServiceLogger) << "Client" << clientName << "not found in whitelist, denying access";'
  '';

  nativeBuildInputs = [
    cmake
    qt6Packages.qttools
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtsvg
    dtkwidget
    qt6integration
    qt6platform-plugins
    libical
  ];

  cmakeFlags = [ "-DVERSION=${finalAttrs.version}" ];

  strictDeps = true;

  meta = with lib; {
    description = "Calendar for Deepin Desktop Environment";
    mainProgram = "dde-calendar";
    homepage = "https://github.com/linuxdeepin/dde-calendar";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
