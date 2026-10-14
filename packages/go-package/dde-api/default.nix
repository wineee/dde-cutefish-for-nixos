{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkg-config,
  deepin-gettext-tools,
  wrapGAppsHook3,
  alsa-lib,
  gtk3,
  libcanberra,
  libgudev,
  librsvg,
  poppler,
  pulseaudio,
  gdk-pixbuf-xlib,
  coreutils,
  dbus,
}:

buildGoModule rec {
  pname = "dde-api";
  version = "6.0.48";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-racnByst4+Un1/rrR241xIpHRUI8HdBBTpRBJOPYIHA=";
  };

  vendorHash = "sha256-Kkw+YTwtjEbfdntlcAjk/sD7tQV0AVXiAeZCqTg7pR0=";

  postPatch = ''
    substituteInPlace misc/systemd/system/deepin-shutdown-sound.service \
      --replace-fail "/usr/bin/true" "${coreutils}/bin/true"

    substituteInPlace sound-theme-player/main.go \
      --replace-fail "/usr/sbin/alsactl" "alsactl"

    substituteInPlace misc/scripts/deepin-boot-sound.sh \
      --replace-fail "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"

    substituteInPlace adjust-grub-theme/main.go language_support/lang_support.go \
      --replace-fail "/usr/share/dde-api" "$out/share/dde-api"

    # Own binaries: the Makefile installs out/bin/* into
    # $out/lib/deepin-api, but the dbus service files and systemd units
    # hardcode /usr/lib/deepin-api (pathsToLink exposes
    # /run/current-system/sw/lib/deepin-api). debian/dde-api.postinst is not
    # installed by the Makefile, so it is intentionally left alone.
    for f in \
      misc/services/org.deepin.dde.Graphic1.service \
      misc/services/org.deepin.dde.LunarCalendar1.service \
      misc/services/org.deepin.dde.Pinyin1.service \
      misc/system-services/org.deepin.dde.Device1.service \
      misc/system-services/org.deepin.dde.LocaleHelper1.service \
      misc/system-services/org.deepin.dde.SoundThemePlayer1.service \
      misc/systemd/system/deepin-api-device.service \
      misc/systemd/system/deepin-locale-helper.service \
      misc/systemd/system/deepin-login-sound.service \
      misc/systemd/system/deepin-shutdown-sound.service \
      misc/systemd/system/deepin-sound-theme-player.service; do
      substituteInPlace "$f" \
        --replace-fail "/usr/lib/deepin-api" "/run/current-system/sw/lib/deepin-api"
    done
  '';

  nativeBuildInputs = [
    pkg-config
    deepin-gettext-tools
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    gtk3
    libcanberra
    libgudev
    librsvg
    poppler
    pulseaudio
    gdk-pixbuf-xlib
  ];

  buildPhase = ''
    runHook preBuild
    make GOBUILD_OPTIONS="$GOFLAGS"
    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    make install DESTDIR="$out" PREFIX="/"
    runHook postInstall
  '';

  postFixup = ''
    for binary in $out/lib/deepin-api/*; do
      wrapProgram $binary "''${gappsWrapperArgs[@]}"
    done
  '';

  meta = with lib; {
    description = "Dbus interfaces used for screen zone detecting, thumbnail generating, sound playing, etc";
    mainProgram = "dde-open";
    homepage = "https://github.com/linuxdeepin/dde-api";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
