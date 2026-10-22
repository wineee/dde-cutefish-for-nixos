{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  runtimeShell,
  icu,
  pcre2, # libpcre2-16, qmltermwidget's own build
  libxkbcommon,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-terminal";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "terminal";
    rev = "bd1d32202d66899d5ba0af55f00d871cc8d9b32c";
    hash = "sha256-4dEgfbaxOij/iv2QGyPzGrjZVbuS1Qmv20kF7OWuppI=";
  };

  # The desktop file and the shell fallbacks assume an FHS layout.
  postPatch = ''
    substituteInPlace cutefish-terminal.desktop \
      --replace-fail "Exec=/usr/bin/" "Exec="
    substituteInPlace qmltermwidget/lib/TerminalSession.cpp \
      --replace-fail '"/bin/bash"' '"${runtimeShell}"' \
      --replace-fail '"/bin/sh"' '"${runtimeShell}"'
    substituteInPlace src/main.cpp \
      --replace-fail '"/bin/sh"' '"${runtimeShell}"'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
    pcre2
    libxkbcommon
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Terminal emulator of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/terminal";
    license = lib.licenses.gpl3Only;
    mainProgram = "cutefish-terminal";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
