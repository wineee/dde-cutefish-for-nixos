{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkg-config,
  deepin-gettext-tools,
  gettext,
  python3,
  wrapGAppsHook3,
  ddcutil,
  alsa-lib,
  glib,
  gtk3,
  libgudev,
  libinput,
  libnl,
  librsvg,
  linux-pam,
  libxcrypt,
  networkmanager,
  pulseaudio,
  gdk-pixbuf-xlib,
  tzdata,
  xkeyboard_config,
  runtimeShell,
  dbus,
  util-linux,
  lshw,
  systemd,
}:

buildGoModule rec {
  pname = "dde-daemon";
  version = "6.1.107";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-Zta+sqTSenwzgABPoFsBDQ7tIJFG8chTF/aU8b4im44=";
  };

  vendorHash = "sha256-iekvou3IWxIZ9VzF5pk+QhLAx6/IrPUvXMhLYMSYAos=";

  postPatch = ''
    # Remove hardcoded PATH overrides
    sed -i '/os.Setenv("PATH"/d' grub2/modify_manger.go bin/dde-system-daemon/main.go

    # Fix /bin/bash references
    find . -name "*.go" -exec sed -i 's|"/bin/bash"|"${runtimeShell}"|g' {} +

    # Fix xkb path
    substituteInPlace inputdevices1/layout_list.go \
      --replace-fail "/usr/share/X11/xkb" "${xkeyboard_config}/share/X11/xkb"

    # Fix timezone paths
    find . -name "*.go" -exec sed -i \
      's|"/usr/share/zoneinfo|"${tzdata}/share/zoneinfo|g' {} +

    # Fix dde-api path
    find . -name "*.go" -exec sed -i \
      's|"/usr/lib/deepin-api|"/run/current-system/sw/lib/deepin-api|g' {} +

    # Fix dde-control-center path
    find . -name "*.go" -exec sed -i \
      's|"/usr/lib/dde-control-center|"/run/current-system/sw/lib/dde-control-center|g' {} +

    # Fix deepin-daemon binary paths
    for file in $(grep -rl "/usr/lib/deepin-daemon" .); do
      sed -i 's|/usr/lib/deepin-daemon|/run/current-system/sw/lib/deepin-daemon|g' "$file"
    done

    # getconf lives in glibc.bin on NixOS, drop the /usr/bin prefix
    find . -name "*.go" -exec sed -i 's|"/usr/bin/getconf"|"getconf"|g' {} +

    # Fix dbus-send in the display brightness systemd task
    substituteInPlace misc/systemd_task/dde-display-task-refresh-brightness.service \
      --replace-fail "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"

    # Fix /usr/share/dde path in zoneinfo
    find . -name "*.go" -exec sed -i \
      's|"/usr/share/dde/zoneinfo|"'$out'/share/dde/zoneinfo|g' {} +

    patchShebangs .
  '';

  # go-gir generates old-style C declarations with () that GCC 14 treats as
  # (void), conflicting with cgo's proper prototypes. Force C11 standard.
  env.CGO_CFLAGS = "-std=gnu11";

  nativeBuildInputs = [
    pkg-config
    deepin-gettext-tools
    gettext
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    ddcutil
    linux-pam
    libxcrypt
    alsa-lib
    glib
    libgudev
    gtk3
    gdk-pixbuf-xlib
    networkmanager
    libinput
    libnl
    librsvg
    pulseaudio
    tzdata
    xkeyboard_config
  ];

  buildPhase = ''
    runHook preBuild
    make GOBUILD_OPTIONS="$GOFLAGS"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install DESTDIR="$out" PREFIX="/"
    runHook postInstall
  '';

  doCheck = false;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${
        lib.makeBinPath [
          util-linux
          glib
          lshw
          systemd
        ]
      }"
    )
  '';

  postFixup = ''
    for binary in $out/lib/deepin-daemon/*; do
      if [ -f "$binary" ] && [ -x "$binary" ]; then
        if file "$binary" | grep -q "ELF"; then
          wrapGApp "$binary"
        fi
      fi
    done
  '';

  meta = with lib; {
    description = "Daemon for handling the deepin session settings";
    homepage = "https://github.com/linuxdeepin/dde-daemon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
