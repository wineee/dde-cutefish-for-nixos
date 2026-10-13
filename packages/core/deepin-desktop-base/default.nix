{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  nixos-icons,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "deepin-desktop-base";
  version = "2026.09.04";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-desktop-base";
    rev = finalAttrs.version;
    hash = "sha256-1Si3mgKxvxAjW9n+7vsVN6xFnDCRs8qYh+o5hbJilE4=";
  };

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
    "PREFIX=/"
  ];

  postInstall = ''
    rm -r $out/etc
    rm -r $out/usr/share/python-apt
    rm -r $out/usr/share/plymouth
    rm -r $out/usr/share/distro-info
    mv $out/usr/* $out/
    rm -r $out/usr

    # The Makefile does not install the distribution identity (only the debian
    # .install does). Provide it ourselves, rebranded to NixOS so the desktop /
    # greeter show NixOS instead of Deepin (logo under NixOS artwork license).
    mkdir -p $out/share/deepin/distribution
    install -D ${./distribution_logo_transparent.svg} $out/share/deepin/distribution/distribution_logo_transparent.svg
    cat > $out/share/deepin/distribution.info <<EOF
    [Distribution]
    Name=NixOS
    WebsiteName=www.nixos.org
    Website=https://www.nixos.org
    Logo=${nixos-icons}/share/icons/hicolor/96x96/apps/nix-snowflake.png
    LogoLight=${nixos-icons}/share/icons/hicolor/32x32/apps/nix-snowflake.png
    LogoTransparent=$out/share/deepin/distribution/distribution_logo_transparent.svg
    EOF
  '';

  meta = {
    description = "Base assets and definitions for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-base";
    license = with lib.licenses; [
      gpl3Plus
      cc-by-40
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
