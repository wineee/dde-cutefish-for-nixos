{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkg-config,
  deepin-gettext-tools,
  gtk3,
  glib,
  libxcrypt,
  gettext,
  iniparser,
  cracklib,
  linux-pam,
}:

buildGoModule rec {
  pname = "deepin-pw-check";
  version = "6.0.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-t/2sBe+fToVXaRMt4UPj0oQ/wqmCrLLe3ymX+oVlgWU=";
  };

  patches = [ "${src}/rpm/0001-Mangle-Suit-Cracklib2.9.6.patch" ];

  vendorHash = "sha256-kgVdodkFC1/9FHhQ8h6MOyu97QX8RkSaWPotIUFj2oI=";

  nativeBuildInputs = [
    pkg-config
    gettext
    deepin-gettext-tools
  ];

  buildInputs = [
    glib
    libxcrypt
    gtk3
    iniparser
    cracklib
    linux-pam
  ];

  postPatch = ''
    sed -i '1i#include <stdlib.h>\n#include <string.h>' tool/pwd_conf_update.c
    substituteInPlace misc/pkgconfig/libdeepin_pw_check.pc \
      --replace-fail "/usr" "$out"
  '';

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install PREFIX="$out" PKG_FILE_DIR=$out/lib/pkgconfig PAM_MODULE_DIR=$out/etc/pam.d
    # https://github.com/linuxdeepin/deepin-pw-check/blob/d5597482678a489077a506a87f06d2b6c4e7e4ed/debian/rules#L21
    ln -s $out/lib/libdeepin_pw_check.so $out/lib/libdeepin_pw_check.so.1
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tool to verify the validity of the password";
    mainProgram = "pwd-conf-update";
    homepage = "https://github.com/linuxdeepin/deepin-pw-check";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
