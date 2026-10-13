{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  gtk3,
  hicolor-icon-theme,
  papirus-icon-theme,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "deepin-icon-theme";
  version = "2026.02.27";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-icon-theme";
    rev = finalAttrs.version;
    hash = "sha256-hSbTrA6MQkaZEGAe9MmvlUe8x+CHT6AWf4ahv5ikiyE=";
  };

  nativeBuildInputs = [ gtk3 ]; # gtk-update-icon-cache

  propagatedBuildInputs = [
    hicolor-icon-theme
    papirus-icon-theme # bloom Inherits=Papirus
  ];

  dontBuild = true;

  # papirus-icon-theme propagates qtbase
  dontWrapQtApps = true;

  # Upstream has broken/dangling symlinks (bloom Inherits blobs referenced via
  # hicolor-links), so skip the symlink check.
  dontCheckForBrokenSymlinks = true;

  installPhase = ''
    runHook preInstall

    for theme in bloom bloom-dark vintage bloom-classic bloom-classic-dark bloom-fantacy Sea; do
      mkdir -p $out/share/icons/$theme
      cp -r $theme/* $out/share/icons/$theme/
    done

    for theme in $out/share/icons/*; do
      if [ -f $theme/index.theme ]; then
        gtk-update-icon-cache $theme
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "Provides the base icon themes on deepin";
    homepage = "https://github.com/linuxdeepin/deepin-icon-theme";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
