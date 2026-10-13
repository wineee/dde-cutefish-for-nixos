{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "deepin-wallpapers";
  version = "1.7.27";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-wallpapers";
    rev = finalAttrs.version;
    hash = "sha256-kh/CskukvXijbXAp8vZx+2IkFqoAnVaTIQU0DvVPbFM=";
  };

  # Pure data package — skip the Makefile (blur generation needs dde-api).
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Mirror the Makefile's prepare step: pick the deepin platform variant.
    cp -r deepin/platform/deepin/* deepin/

    mkdir -p $out/share/wallpapers/deepin
    cp -r deepin/*.jpg deepin/*.jpeg deepin/*.png $out/share/wallpapers/deepin/ 2>/dev/null || true

    mkdir -p $out/share/backgrounds
    ln -s $out/share/wallpapers/deepin/desktop.jpg $out/share/backgrounds/default_background.jpg
    runHook postInstall
  '';

  meta = {
    description = "Deepin-wallpapers provides wallpapers of dde";
    homepage = "https://github.com/linuxdeepin/deepin-wallpapers";
    license = with lib.licenses; [
      gpl3Plus
      cc-by-sa-30
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
