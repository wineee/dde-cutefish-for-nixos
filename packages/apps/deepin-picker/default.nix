{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  qt6Packages,
  dtkwidget,
  dtkgui,
  libxtst,
  libxcb,
  libxcb-util,
}:

stdenv.mkDerivation rec {
  pname = "deepin-picker";
  version = "6.0.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-dp5+7HwtUa52aMn3VwATqFZ3H+DS+kqsnluzFf/xy8k=";
  };

  postPatch = ''
    substituteInPlace com.deepin.Picker.service \
      --replace "/usr/bin/deepin-picker" "$out/bin/deepin-picker"

    # Do not rely on distro-specific hardcoded lrelease/lupdate paths
    substituteInPlace deepin-picker.pro \
      --replace "/usr/lib/qt6/bin/lrelease" "lrelease" \
      --replace "/usr/lib/qt6/bin/lupdate" "lupdate"
  '';

  nativeBuildInputs = [
    qt6Packages.qmake
    qt6Packages.qttools
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtsvg
    dtkwidget
    dtkgui
    libxtst
    libxcb
    libxcb-util
  ];

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
    "BINDIR=${placeholder "out"}/bin"
    "ICONDIR=${placeholder "out"}/share/icons/hicolor/scalable/apps"
    "APPDIR=${placeholder "out"}/share/applications"
    "DSRDIR=${placeholder "out"}/share/deepin-picker"
    "DOCDIR=${placeholder "out"}/share/dman/deepin-picker"
  ];

  meta = {
    description = "Color picker application";
    mainProgram = "deepin-picker";
    homepage = "https://github.com/linuxdeepin/deepin-picker";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.deepin ];
  };
}
