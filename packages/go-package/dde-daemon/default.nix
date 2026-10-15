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
  version = "6.1.108";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-etJmYQ7ZyRuqMbfSXzpAD4M9KG10S600jEQp8TJF/Ik=";
  };

  vendorHash = "sha256-iekvou3IWxIZ9VzF5pk+QhLAx6/IrPUvXMhLYMSYAos=";

  patches = [
    # Drop the hardcoded PATH setenv (breaks nix's wrapped PATH injection).
    ./0001-dont-set-PATH.patch
  ];

  postPatch = ''
    # /bin/bash -> runtimeShell (non-test sources only; *_test.go not built)
    substituteInPlace accounts1/users/manager.go \
      display1/manager.go \
      session/eventlog/login_event.go \
      --replace-fail '"/bin/bash"' '"${runtimeShell}"'

    # xkb layout rules
    substituteInPlace inputdevices1/layout_list.go \
      --replace-fail "/usr/share/X11/xkb" "${xkeyboard_config}/share/X11/xkb"

    # timezone data lives in the tzdata package
    substituteInPlace display1/color_temp.go \
      timedate1/manager.go \
      timedate1/zoneinfo/zone.go \
      --replace-fail '"/usr/share/zoneinfo' '"${tzdata}/share/zoneinfo'

    # dde-api / dde-control-center helper paths
    substituteInPlace grub2/modify_manger.go \
      --replace-fail '"/usr/lib/deepin-api' '"/run/current-system/sw/lib/deepin-api'
    substituteInPlace accounts1/user_chpwd_union_id.go \
      --replace-fail '"/usr/lib/dde-control-center' '"/run/current-system/sw/lib/dde-control-center'

    # deepin-daemon own binaries (pathsToLink exposes /run/current-system/sw)
    substituteInPlace accounts1/user.go \
      bin/dde-system-daemon/main.go \
      bin/search/main.go \
      bluetooth1/utils_notify.go \
      display1/manager.go \
      keybinding1/shortcuts/media_shortcut.go \
      keybinding1/shortcuts/system_shortcut.go \
      keybinding1/special_keycode.go \
      service_trigger/manager.go \
      --replace-fail '"/usr/lib/deepin-daemon' '"/run/current-system/sw/lib/deepin-daemon'

    # getconf lives in glibc.bin on NixOS, drop the /usr/bin prefix
    substituteInPlace system/systeminfo1/manager.go \
      systeminfo1/utils.go \
      --replace-fail '"/usr/bin/getconf"' '"getconf"'

    # dbus-send in the display brightness systemd task
    substituteInPlace misc/systemd_task/dde-display-task-refresh-brightness.service \
      --replace-fail "/usr/bin/dbus-send" "${dbus}/bin/dbus-send"

    # zoneinfo defaults ship with dde-daemon's own data
    substituteInPlace timedate1/zoneinfo/zone.go \
      --replace-fail '"/usr/share/dde/zoneinfo' '"'$out'/share/dde/zoneinfo'

    # Own data files (Makefile installs misc/dde-daemon/* into $out/share/dde-daemon)
    substituteInPlace accounts1/manager.go \
      bin/dde-system-daemon/virtual.go \
      keybinding1/shortcuts/media_shortcut.go \
      --replace-fail '"/usr/share/dde-daemon' '"'$out'/share/dde-daemon'

    # Own helper scripts (keybinding shortcuts)
    substituteInPlace keybinding1/shortcuts/system_shortcut.go \
      --replace-fail '"/usr/libexec/dde-daemon' '"'$out'/libexec/dde-daemon'

    # deepin themes + xsessions come from other packages (pathsToLink)
    substituteInPlace accounts1/user.go \
      --replace-fail '"/usr/share/deepin-themes/' '"/run/current-system/sw/share/deepin-themes/' \
      --replace-fail '"/usr/share/xsessions"' '"/run/current-system/sw/share/xsessions"'

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
