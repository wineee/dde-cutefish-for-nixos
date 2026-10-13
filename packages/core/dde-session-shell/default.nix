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

  postPatch = ''
    # Fix hardcoded qdbusxml2cpp path
    substituteInPlace CMakeLists.txt \
      --replace-fail '/usr/lib/qt''${QT_VERSION_MAJOR}/bin/qdbusxml2cpp' \
                     '${qt6Packages.qtbase}/bin/qdbusxml2cpp'

    # Remove liblightdm-qt6-3 requirement — dde-lock doesn't actually use LightDM APIs.
    # The greeter does, but we skip building it since nixpkgs has no Qt6 lightdm bindings.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'pkg_check_modules(Greeter REQUIRED liblightdm-qt6-3)' \
                     '# pkg_check_modules(Greeter REQUIRED liblightdm-qt6-3) -- patched out for NixOS'

    # Remove spurious Greeter_LIBRARIES from dde-lock link line
    substituteInPlace CMakeLists.txt \
      --replace-fail '    ''${Greeter_LIBRARIES}
    PkgConfig::SSL
)
if (DISABLE_DSS_SNIPE)' \
                     '    PkgConfig::SSL
)
if (DISABLE_DSS_SNIPE)'

    # Don't build lightdm-deepin-greeter (needs liblightdm-qt6-3 which doesn't exist in nixpkgs).
    # Wrap the entire greeter block in if(FALSE)...endif() to skip it cleanly.
    # The block covers: GREETER_SRCS, add_executable, target_include/compile/link for greeter.
    sed -i '/^set(GREETER_SRCS/i if(FALSE) # NixOS: skip greeter (no liblightdm-qt6-3)' CMakeLists.txt
    sed -i '/^add_subdirectory(tests)/i endif() # NixOS: end skip greeter' CMakeLists.txt

    # Also skip tests (they reference the greeter target)
    substituteInPlace CMakeLists.txt \
      --replace-fail 'add_subdirectory(tests)' \
                     '# add_subdirectory(tests) -- disabled for NixOS'

    # Remove greeter from install targets (both binaries need liblightdm-qt6-3)
    substituteInPlace CMakeLists.txt \
      --replace-fail 'install(TARGETS lightdm-deepin-greeter greeter-display-setting DESTINATION ''${CMAKE_INSTALL_BINDIR})' \
                     '# install(TARGETS lightdm-deepin-greeter greeter-display-setting) -- patched out for NixOS'

    # Fix hardcoded /usr paths in source code
    find . \( -name "*.cpp" -o -name "*.h" \) -exec sed -i \
      -e 's|/usr/share|/run/current-system/sw/share|g' \
      -e 's|/usr/lib|/run/current-system/sw/lib|g' {} +

    # Fix hardcoded paths in service and desktop files
    find . \( -name "*.service" -o -name "*.desktop" \) -exec sed -i \
      -e "s|/usr/bin|$out/bin|g" \
      -e "s|/usr/lib|$out/lib|g" {} +

    # Fix CMake install paths
    find . -name "CMakeLists.txt" -exec sed -i \
      -e "s|/etc/|$out/etc/|g" {} +

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
