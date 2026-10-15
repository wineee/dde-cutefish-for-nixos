{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  glib,
  util-linux,
  libnl,
  lucenepp,
  boost,
  spdlog,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deepin-anything";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-anything";
    tag = finalAttrs.version;
    hash = "sha256-nj8I4hm/OyfMNq7PmX3XlRIbYSvvFGylpBHbrChqa+Q=";
  };

  # vfs_monitor.ko is built separately (see deepin-anything-module) and pulled
  # in by the NixOS module; upstream's DKMS glue is not usable here.
  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail 'add_subdirectory("kernelmod")' ""
  '';

  # Upstream installs with relative DESTINATIONs, so everything lands under
  # $out once the prefix is set; only the systemd units still `ExecStart`
  # /usr/libexec/<bin>, which postInstall rewrites to our libexec dir.
  cmakeFlags = [
    # CMake 4.x dropped compatibility with `cmake_minimum_required` < 3.5.
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  # pinyin_processor.cpp uses std::wstring_convert, deprecated in libstdc++ 15
  # and fatal because the project builds with -Werror.
  env.NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    glib
    util-linux
    libnl
    lucenepp
    boost
    spdlog
  ];

  postInstall = ''
    # The units hardcode `ExecStart=/usr/libexec/<bin>`; repoint them at $out.
    # (The server unit is not installed by upstream CMake — it is left to the
    # packaging layer — so only these two exist here.)
    substituteInPlace $out/lib/systemd/system/deepin-anything-logger.service \
      $out/lib/systemd/user/deepin-anything-daemon.service \
      --replace-fail "/usr/libexec" "$out/libexec"
  '';

  meta = {
    description = "Deepin Anything file search tool";
    homepage = "https://github.com/linuxdeepin/deepin-anything";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
