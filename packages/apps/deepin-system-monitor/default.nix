{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  deepin-gettext-tools,
  qt6Packages,
  kdePackages,
  dtkwidget,
  dtkgui,
  dtkcore,
  libpcap,
  libnl,
  util-linux,
  systemd,
  polkit,
  icu,
  libxcb,
  libxext,
  libxcb-wm,
}:

stdenv.mkDerivation rec {
  pname = "deepin-system-monitor";
  version = "6.5.47";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-c3zouzVc//tAk6yl7jCeHCyl9uaBTYKqyY31hGoaEwk=";
  };

  postPatch = ''
    # Dock plugin/popup require dde-dock headers which are not packaged here;
    # build only the main app + daemon + dbus/system servers.
    substituteInPlace CMakeLists.txt \
      --replace-fail "ADD_SUBDIRECTORY(deepin-system-monitor-plugin)" "" \
      --replace-fail "ADD_SUBDIRECTORY(deepin-system-monitor-plugin-popup)" ""

    # Drop the global -pie (breaks the daemon MODULE target on CMake 4.x).
    substituteInPlace CMakeLists.txt \
      --replace-fail "-Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -pie -fstack-protector-all" \
                     "-Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -fstack-protector-all"

    # Install the privileged backend under the Nix prefix.
    substituteInPlace deepin-system-monitor-system-server/CMakeLists.txt \
      --replace-fail "/usr/lib/deepin-daemon/" "$out/lib/deepin-daemon/"

    # Fix runtime tool/service paths.
    substituteInPlace deepin-system-monitor-main/service/service_manager.cpp \
      --replace-fail "/usr/bin/pkexec" "${lib.getBin polkit}/bin/pkexec" \
      --replace-fail "/usr/bin/systemctl" "${lib.getBin systemd}/bin/systemctl"

    # kill/renice live in different files; previously both files got both
    # substitutions, and the two that did not match were silently ignored.
    substituteInPlace deepin-system-monitor-main/process/process_controller.cpp \
      --replace-fail "/usr/bin/kill" "${lib.getBin util-linux}/bin/kill"
    substituteInPlace deepin-system-monitor-main/process/priority_controller.cpp \
      --replace-fail "/usr/bin/renice" "${lib.getBin util-linux}/bin/renice"

    substituteInPlace deepin-system-monitor-server/src/dbusserver.cpp \
      --replace-fail "/usr/bin/deepin-system-monitor" "$out/bin/deepin-system-monitor"
    substituteInPlace deepin-system-monitor-server/com.deepin.SystemMonitorServer.service \
      --replace-fail "/usr/bin/deepin-system-monitor-server" "$out/bin/deepin-system-monitor-server"
    substituteInPlace deepin-system-monitor-system-server/misc/org.deepin.deepin-system-monitor-system-server.policy \
      --replace-fail "/usr/bin/deepin-system-monitor" "$out/bin/deepin-system-monitor"
    substituteInPlace deepin-system-monitor-system-server/misc/deepin-system-monitor-system-server.service \
      --replace-fail "/usr/lib/deepin-daemon/deepin-system-monitor-system-server" "$out/lib/deepin-daemon/deepin-system-monitor-system-server"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    deepin-gettext-tools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dtkgui
    dtkcore
    qt6Packages.qtbase
    qt6Packages.qtsvg
    kdePackages.polkit-qt-1
    libpcap
    libnl
    systemd
    icu
    libxcb
    libxext
    libxcb-wm
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  # The dtk*/polkit-qt-1/ICU pkg-config/cmake deps are resolved transitively.
  strictDeps = false;

  meta = with lib; {
    description = "More user-friendly system monitor";
    homepage = "https://github.com/linuxdeepin/deepin-system-monitor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
