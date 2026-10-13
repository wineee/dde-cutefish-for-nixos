{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dde-account-faces";
  version = "1.0.19";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-account-faces";
    rev = finalAttrs.version;
    hash = "sha256-cKvcF3s8nFjIXjdQJd6oAoiJJ2vgwrL0DLh9aUc9JBc=";
  };

  # Pure data package — no compilation needed
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/var/lib/AccountsService
    cp -r icons $out/var/lib/AccountsService/
    runHook postInstall
  '';

  meta = {
    description = "Account faces of deepin desktop environment";
    homepage = "https://github.com/linuxdeepin/dde-account-faces";
    license = with lib.licenses; [
      gpl3Plus
      cc0
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
