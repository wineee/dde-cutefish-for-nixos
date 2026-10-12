{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkwidget,
  dtkgui,
  dtkcore,
  libx11,
  libxscrnsaver,
  libxext,
  libxcb,
  xscreensaver,
}:

stdenv.mkDerivation rec {
  pname = "deepin-screensaver";
  version = "6.5.11";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-dQIYkEA+hWVdBlvFyU2CARlsJIe74gTiwqfHkY4oWKQ=";
  };

  postPatch = ''
    # Use the Qt6::lrelease imported target instead of a distro hardcoded path
    substituteInPlace cmake/translation-generate.cmake \
      --replace-fail 'set(QT_LRELEASE "/lib/qt''${QT_VERSION_MAJOR}/bin/lrelease")' \
                     'get_target_property(QT_LRELEASE Qt''${QT_VERSION_MAJOR}::lrelease IMPORTED_LOCATION)'

    # Install into the Nix prefix instead of absolute /usr//etc paths.
    substituteInPlace customscreensaver/saverpic/CMakeLists.txt \
      --replace "/usr/lib/deepin-screensaver/modules" "$out/lib/deepin-screensaver/modules"
    substituteInPlace customscreensaver/deepin-custom-screensaver/CMakeLists.txt \
      --replace "/usr/lib/deepin-screensaver/modules" "$out/lib/deepin-screensaver/modules" \
      --replace "/usr/share/dconfig/overrides" "$out/share/dconfig/overrides" \
      --replace "/etc/deepin-screensaver/deepin-custom-screensaver" "$out/etc/deepin-screensaver/deepin-custom-screensaver"

    # Fix runtime paths embedded in sources
    substituteInPlace src/com.deepin.ScreenSaver.service \
      --replace "/usr/bin/deepin-screensaver" "$out/bin/deepin-screensaver"
    substituteInPlace src/dbusscreensaver.cpp \
      --replace "/usr/bin/deepin-screensaver" "$out/bin/deepin-screensaver"
    substituteInPlace src/utils.cpp \
      --replace "/etc/deepin-screensaver/" "$out/etc/deepin-screensaver/"
    substituteInPlace tools/preview/main.cpp \
      --replace "/usr/lib/xscreensaver" "${xscreensaver}/libexec/xscreensaver"
    substituteInPlace customscreensaver/deepin-custom-screensaver/data/deepin-custom-screensaver.desktop \
      --replace "/usr/lib/deepin-screensaver/modules/deepin-custom-screensaver" "$out/lib/deepin-screensaver/modules/deepin-custom-screensaver"

    # Neutralize the xscreensaver subdir (Debian postinst regeneration).
    substituteInPlace CMakeLists.txt \
      --replace "add_subdirectory(xscreensaver)" ""

    # Qt6::GuiPrivate is linked but never found (the find_package lists only
    # Gui/Widgets/DBus/Quick); add the missing find_package for it.
    substituteInPlace src/CMakeLists.txt \
      --replace 'find_package(Qt''${QT_DESIRED_VERSION} REQUIRED COMPONENTS ''${qt_required_components})' \
                'find_package(Qt''${QT_DESIRED_VERSION} REQUIRED COMPONENTS ''${qt_required_components} GuiPrivate)'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dtkgui
    dtkcore
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qt5compat
    libx11
    libxscrnsaver
    libxext
    libxcb
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DXSCREENSAVER_DATA_PATH=${xscreensaver}/libexec/xscreensaver"
  ];

  meta = with lib; {
    description = "Screensaver service developed by deepin";
    mainProgram = "deepin-screensaver";
    homepage = "https://github.com/linuxdeepin/deepin-screensaver";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    teams = [ teams.deepin ];
  };
}
