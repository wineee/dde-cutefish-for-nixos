{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  pam,
  cutefish-toolkit,
  cutefish-compositor,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-dm";
  version = "1.0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "cutefish-dm";
    rev = "73ed274f3ec27af8e4e118f428073769fc4e873a";
    hash = "sha256-eg3oh55IqlOKhX0nneuDaYnRjrE8Zzz/UWPyly3ao/E=";
  };

  postPatch = ''
    # Units of a package are collected from $out/lib/systemd.
    substituteInPlace CMakeLists.txt \
      --replace-fail "DESTINATION /usr/lib/systemd/system" "DESTINATION lib/systemd/system" \
      --replace-fail "DESTINATION /usr/lib/systemd/user" "DESTINATION lib/systemd/user"
    substituteInPlace data/cutefish-dm.service \
      --replace-fail "ExecStart=/usr/bin/cutefish-dm" "ExecStart=${placeholder "out"}/bin/cutefish-dm"
    # The login screen is the compositor itself, and sessions are described by
    # desktop entries in the system profile.
    substituteInPlace daemon/config.h \
      --replace-fail '{"/usr/bin/cutefish-compositor", "--login"}' \
        '{"${cutefish-compositor}/bin/cutefish-compositor", "--login"}' \
      --replace-fail '{"/usr/local/share/wayland-sessions", "/usr/share/wayland-sessions"}' \
        '{"/run/current-system/sw/share/wayland-sessions"}'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    pam
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Display manager of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/cutefish-dm";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-dm";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
