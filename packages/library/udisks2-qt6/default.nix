{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  udisks2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "udisks2-qt6";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "udisks2-qt6";
    rev = finalAttrs.version;
    hash = "sha256-JZgeeNznmIYTwA4HgH6a8UayvrNAOqMQYUGkjmQjc8w=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  dontWrapQtApps = true;

  # nixpkgs passes CMAKE_INSTALL_LIBDIR/INCLUDEDIR as absolute paths, so the
  # upstream `\${prefix}/@CMAKE_INSTALL_*@` form double-prefixes the .pc.
  # Use the _FULL_ variants (already absolute) instead.
  patches = [
    ./fix-pc-double-prefix.patch
  ];

  buildInputs = [
    qt6Packages.qtbase
    udisks2
  ];

  meta = {
    description = "UDisks2 D-Bus interfaces binding for Qt6";
    homepage = "https://github.com/linuxdeepin/udisks2-qt6";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
