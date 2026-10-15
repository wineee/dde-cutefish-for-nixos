{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  dtkcore,
  dtkwidget,
  dtkcommon,
  deepin-gettext-tools,
  linux-pam,
  openssl,
  libxcb,
  xcbutilwm,
  libx11,
  libxi,
  libxcursor,
  libxfixes,
  libxrandr,
  libxext,
  libxtst,
  setxkbmap,
  xdotool,
  systemd,
  gtest,
  glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dde-session-shell";
  version = "6.0.68";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "dde-session-shell-snipe";
    rev = finalAttrs.version;
    hash = "sha256-hqv8dd3GiXpR1PaPCry7ob1OL/7EkI+gJ5JCeOm0dnQ=";
  };

  # Drops the greeter (needs liblightdm-qt6-3, which nixpkgs has no Qt6 bindings
  # for) and the tests that link against it: comments out the Greeter pkg-config
  # check and the greeter install rule, and wraps the whole greeter block in
  # if(FALSE)...endif(). A patch keeps the block boundaries reviewable; the sed
  # + substituteInPlace pair it replaces could not be checked by reading.
  patches = [ ./0001-skip-greeter-and-tests.patch ];

  postPatch = ''
    # Fix hardcoded qdbusxml2cpp path
    substituteInPlace CMakeLists.txt \
      --replace-fail '/usr/lib/qt''${QT_VERSION_MAJOR}/bin/qdbusxml2cpp' \
                     '${qt6Packages.qtbase}/bin/qdbusxml2cpp'

    # Data dirs (translations, backgrounds, icons, plugin modules) live in other
    # packages and are merged into the system profile.
    substituteInPlace src/global_util/constants.h \
      --replace-fail '/usr/share/icons/default/index.theme' '/run/current-system/sw/share/icons/default/index.theme' \
      --replace-fail '/usr/share/dde-session-shell/dde-session-shell.conf' '/run/current-system/sw/share/dde-session-shell/dde-session-shell.conf' \
      --replace-fail '/usr/share/dde-session-ui/dde-session-ui.conf' '/run/current-system/sw/share/dde-session-ui/dde-session-ui.conf' \
      --replace-fail '/usr/share/dde-session-ui/dde-shutdown.conf' '/run/current-system/sw/share/dde-session-ui/dde-shutdown.conf'
    substituteInPlace src/global_util/public_func.cpp \
      --replace-fail '/usr/share/icons/bloom/cursors/loginspinner' '/run/current-system/sw/share/icons/bloom/cursors/loginspinner' \
      --replace-fail '/usr/share/dde-session-shell/translations/dde-session-shell_' '/run/current-system/sw/share/dde-session-shell/translations/dde-session-shell_'
    substituteInPlace src/global_util/xkbparser.h \
      --replace-fail '/usr/share/X11/xkb/rules/base.xml' '/run/current-system/sw/share/X11/xkb/rules/base.xml'
    substituteInPlace lighter-greeter/lighterbackground.cpp \
      src/session-widgets/userinfo.cpp \
      src/widgets/fullscreenbackground.cpp \
      --replace-fail '/usr/share/backgrounds/default_background.jpg' '/run/current-system/sw/share/backgrounds/default_background.jpg'
    substituteInPlace src/session-widgets/lockcontent.cpp \
      --replace-fail '/usr/share/backgrounds/deepin/desktop.jpg' '/run/current-system/sw/share/backgrounds/deepin/desktop.jpg'
    substituteInPlace src/global_util/plugin_manager/modules_loader.cpp \
      --replace-fail '/usr/lib/dde-session-shell/modules' '/run/current-system/sw/lib/dde-session-shell/modules'
    substituteInPlace src/session-widgets/auth_module.h \
      --replace-fail '/usr/lib/dde-control-center/reset-password-dialog' '/run/current-system/sw/lib/dde-control-center/reset-password-dialog' \
      --replace-fail '/usr/lib/deepin-deepinid-daemon/deepin-deepinid-daemon' '/run/current-system/sw/lib/deepin-deepinid-daemon/deepin-deepinid-daemon'

    # Keyboard grab/ungrab shells out to setxkbmap+xdotool; systemd-detect-virt
    # gates the hibernate button.
    substituteInPlace src/global_util/keyboardmonitor/keyboardplantform_wayland.cpp \
      --replace-fail '/usr/bin/setxkbmap' '${setxkbmap}/bin/setxkbmap' \
      --replace-fail '/usr/bin/xdotool' '${xdotool}/bin/xdotool'
    substituteInPlace src/session-widgets/auth_password.cpp \
      --replace-fail '/usr/bin/setxkbmap' '${setxkbmap}/bin/setxkbmap'
    substituteInPlace src/session-widgets/authinterface.cpp \
      --replace-fail '/usr/bin/systemd-detect-virt' '${systemd}/bin/systemd-detect-virt'

    # pam_inhibit_autologin execs pre-greeter, which reads launch.conf.d.
    substituteInPlace src/pam-inhibit-autologin/pam_inhibit_autologin.c \
      --replace-fail '/usr/share/dde-session-shell/greeters.d/pre-greeter' '/run/current-system/sw/share/dde-session-shell/greeters.d/pre-greeter'
    substituteInPlace files/pre-greeter \
      --replace-fail '/usr/share/dde-session-shell/greeters.d/launch.conf.d' '/run/current-system/sw/share/dde-session-shell/greeters.d/launch.conf.d'

    # bin/dde-lock is this wrapper; with the FHS path it execs nothing.
    substituteInPlace files/dde-lock-loader-wrapper \
      --replace-fail '/usr/libexec/deepin/dde-lock' "$out/libexec/deepin/dde-lock"

    substituteInPlace files/dde-lock.desktop \
      files/snipe/dde-lock.desktop \
      files/snipe/org.deepin.dde.LockFront1.service \
      --replace-fail '/usr/bin/dde-lock' "$out/bin/dde-lock"
    substituteInPlace files/com.deepin.dde.lockFront.service \
      files/com.deepin.dde.shutdownFront.service \
      files/snipe/org.deepin.dde.ShutdownFront1.service \
      --replace-fail '/usr/bin/dbus-send' '${glib.bin}/bin/dbus-send' \
      --replace-fail '/usr/share/applications/dde-lock.desktop' "$out/share/applications/dde-lock.desktop"
    substituteInPlace files/deepin-log-config/org.deepin.dde.session-shell.json \
      --replace-fail '/usr/bin/dde-lock' "$out/bin/dde-lock"

    # dde-session-shell.conf goes to /var/lib/dde-session-shell in the snipe
    # branch; redirect it to our output (runtime uses DConfig now).
    substituteInPlace CMakeLists.txt \
      --replace-fail 'install(FILES files/dde-session-shell.conf DESTINATION /var/lib/dde-session-shell/)' \
                     'install(FILES files/dde-session-shell.conf DESTINATION ''${CMAKE_INSTALL_DATADIR}/dde-session-shell/)'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.qttools
    qt6Packages.wrapQtAppsHook
    deepin-gettext-tools
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtsvg
    qt6Packages.qtdeclarative
    dtkcore
    dtkwidget
    dtkcommon
    linux-pam
    openssl
    libxcb
    xcbutilwm
    libx11
    libxi
    libxcursor
    libxfixes
    libxrandr
    libxext
    libxtst
    setxkbmap
    xdotool
    systemd
    gtest
    glib
  ];

  cmakeFlags = [
    "-DDDE_SESSION_SHELL_SNIPE=ON"
    "-DBUILD_TESTING=OFF"
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = {
    description = "Lock screen and greeter for DDE (Deepin Desktop Environment)";
    homepage = "https://github.com/linuxdeepin/dde-session-shell-snipe";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
