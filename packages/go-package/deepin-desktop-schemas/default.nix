{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  glib,
}:

buildGoModule rec {
  pname = "deepin-desktop-schemas";
  version = "6.0.13";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-2WGrda800xIFlOrSkbEeF4MKTDIhYMhwervB1xu2nZA=";
  };

  vendorHash = "sha256-q6ugetchJLv2JjZ9+nevUI0ptizh2V+6SByoY/eFJJQ=";

  postPatch = ''
    # Relocate backgrounds/wallpapers paths to the NixOS system profile.
    # Only the schemas/ and overrides/ trees end up installed (build copies
    # them into result/ and installs result/*.xml + result/*.override); the
    # debian/rpm/archlinux packaging dirs are not installed and left alone.
    substituteInPlace overrides/common/com.deepin.wrap.gnome.desktop.override \
      overrides/mips/appearance.override \
      overrides/sw/appearance.override \
      schemas/com.deepin.dde.appearance.gschema.xml \
      schemas/wrap/com.deepin.wrap.gnome.desktop.app-folders.gschema.xml \
      schemas/wrap/com.deepin.wrap.gnome.desktop.background.gschema.xml \
      schemas/wrap/com.deepin.wrap.gnome.desktop.screensaver.gschema.xml \
      --replace-fail "/usr/share" "/run/current-system/sw/share"
  '';

  buildPhase = ''
    runHook preBuild
    make ARCH=${stdenv.hostPlatform.linuxArch}
    runHook postBuild
  '';

  nativeCheckInputs = [ glib ];
  checkPhase = ''
    runHook preCheck
    make test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    make install DESTDIR="$out" PREFIX="/"
    runHook postInstall
  '';

  meta = {
    description = "GSettings deepin desktop-wide schemas";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-schemas";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
