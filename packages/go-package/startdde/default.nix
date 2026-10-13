{
  lib,
  buildGoModule,
  fetchFromGitHub,
  gettext,
  pkg-config,
  jq,
  wrapGAppsHook3,
  glib,
  libgnome-keyring,
  gtk3,
  alsa-lib,
  pulseaudio,
  libgudev,
  libsecret,
  runtimeShell,
  dbus,
  tzdata,
}:

buildGoModule rec {
  pname = "startdde";
  version = "6.1.6";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-znpp5lyGNUTHfyHcIu05pCWgzdNB0sKr+jNPZm+86O4=";
  };

  vendorHash = "sha256-DaDF/1RI2XJ8R/RvsKKRISLJlI7+4EwXjIlJWWma2zk=";

  postPatch = ''
    substituteInPlace display/manager.go \
      --replace-fail "/bin/bash" "${runtimeShell}"

    substituteInPlace misc/systemd_task/dde-display-task-refresh-brightness.service \
       --replace-fail "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"

    substituteInPlace display/manager.go \
      --replace-fail "/usr/lib/deepin-daemon" "/run/current-system/sw/lib/deepin-daemon"

    # NixOS keeps zoneinfo in the tzdata package, not /usr/share/zoneinfo.
    substituteInPlace display/color_temp.go \
      --replace-fail '"/usr/share/zoneinfo/zone1970.tab"' '"${tzdata}/share/zoneinfo/zone1970.tab"'

    substituteInPlace misc/lightdm.conf --replace-fail "/usr" "$out"
  '';

  nativeBuildInputs = [
    gettext
    pkg-config
    jq
    wrapGAppsHook3
    glib
  ];

  buildInputs = [
    libgnome-keyring
    gtk3
    alsa-lib
    pulseaudio
    libgudev
    libsecret
  ];

  # go-gir generates old-style C declarations with () that GCC 14 treats as
  # (void), conflicting with cgo's proper prototypes. Force C11 standard.
  env.CGO_CFLAGS = "-std=gnu11";

  buildPhase = ''
    runHook preBuild
    make GO_BUILD_FLAGS="$GOFLAGS"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install DESTDIR="$out" PREFIX="/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Starter of deepin desktop environment";
    homepage = "https://github.com/linuxdeepin/startdde";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
