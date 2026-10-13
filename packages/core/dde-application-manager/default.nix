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
  version = "1.2.62";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-application-manager";
    rev = finalAttrs.version;
    hash = "sha256-RY5hKW8ze+cTNE1+u71j9b3qCAjWj+VjKGXCXuURoAc=";
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
