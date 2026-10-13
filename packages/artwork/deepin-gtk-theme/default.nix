{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "deepin-gtk-theme";
  version = "25.3.7";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-gtk-theme";
    rev = finalAttrs.version;
    hash = "sha256-RbhbyxU/n+7JfW5vV4ORPtLlRqSG2BLhjb/UusR2JTo=";
  };

  # Pure data package — the Makefile just copies theme dirs.
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    cp -r deepin $out/share/themes/
    cp -r deepin-dark $out/share/themes/
    runHook postInstall
  '';

  meta = {
    description = "Deepin GTK Theme";
    homepage = "https://github.com/linuxdeepin/deepin-gtk-theme";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
