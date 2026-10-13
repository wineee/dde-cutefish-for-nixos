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
      substituteInPlace $file --replace "/bin/bash" "${runtimeShell}"
    done
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
