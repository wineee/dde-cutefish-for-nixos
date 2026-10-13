{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  kdePackages,
  dtkcore,
  dtkgui,
  lomiri-qt6,
  deepin-service-manager,
  glib,
  gtk3,
  libxcursor,
  libxfixes,
  libx11,
  libxcb,
  xcbutilcursor,
  fontconfig,
  openssl,
  systemd,
  tzdata,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-appearance";
  version = "1.1.86";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-appearance";
    rev = finalAttrs.version;
    hash = "sha256-kFmYWIoQYVQWFqsiJin5XCaUIi/RquWnY4OSWBVgjg4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    kdePackages.kwindowsystem
    kdePackages.kconfig
    kdePackages.kglobalaccel
    dtkcore
    dtkgui
    lomiri-qt6.gsettings-qt
    deepin-service-manager
    glib
    gtk3
    libxcursor
    libxfixes
    libx11
    libxcb
    xcbutilcursor
    fontconfig
    openssl
    systemd
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
  ];

  postPatch = ''
    # Fix hardcoded /etc paths in CMakeLists
    find . -name "CMakeLists.txt" -exec \
      sed -i "s|/etc/|$out/etc/|g" {} +

    # Fix systemd user unit install path
    find . -name "CMakeLists.txt" -exec \
      sed -i "s|\''${SYSTEMD_USER_UNIT_DIR}|$out/lib/systemd/user|g" {} +

    # Fix timezone data path
    substituteInPlace src/service/modules/common/commondefine.h \
      --replace-fail '"/usr/share/zoneinfo/zone1970.tab"' '"${tzdata}/share/zoneinfo/zone1970.tab"'

    # nixpkgs lomiri-qt6.gsettings-qt 的 .pc 只提供 -I.../include/qt6/QGSettings，
    # 不支持 deepin 的 `#include <QGSettings/QGSettings>`；改用标准风格。
    substituteInPlace src/service/modules/api/themes.cpp \
      --replace-fail '#include <QGSettings/QGSettings>' '#include <QGSettings>'

    # Fix hardcoded /usr/share paths to use $out
    substituteInPlace src/service/modules/api/compatibleengine.cpp \
      --replace-fail '"/usr/share/dsg/icons/"' '"'"$out"'/share/dsg/icons/"'
    substituteInPlace src/service/modules/subthemes/customtheme.cpp \
      --replace-fail '"/usr/share/dde-appearance/' '"'"$out"'/share/dde-appearance/'
  '';

  SYSTEMD_USER_UNIT_DIR = "${placeholder "out"}/lib/systemd/user";

  meta = {
    description = "Appearance management service for DDE";
    homepage = "https://github.com/linuxdeepin/dde-appearance";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
