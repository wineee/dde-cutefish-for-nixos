{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkcore,
  systemd,
  treeland-protocols,
  libxkbcommon,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-application-manager";
  version = "1.2.45";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-application-manager";
    rev = finalAttrs.version;
    hash = "sha256-HeHVjO3+sKwnkMbA19XbIVpR6iqpOKxk2w0VbxTgmZ0=";
  };

  postPatch = ''
    # Fix hardcoded /etc paths
    find . -name "CMakeLists.txt" -exec \
      sed -i "s|/etc/|$out/etc/|g" {} +
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtwayland
    dtkcore
    systemd
    treeland-protocols
    libxkbcommon
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
    "-DCMAKE_INSTALL_LIBEXECDIR=lib"
    "-DBUILD_TESTING=OFF"
  ];

  # Remove Debian-specific dpkg config
  postInstall = ''
    rm -rf $out/etc/dpkg
  '';

  meta = {
    description = "Application manager for Deepin Desktop Environment";
    mainProgram = "dde-application-manager";
    homepage = "https://github.com/linuxdeepin/dde-application-manager";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
