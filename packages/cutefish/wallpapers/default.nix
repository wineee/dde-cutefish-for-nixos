{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-wallpapers";
  version = "1.0-unstable-2026-10-19";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "wallpapers";
    rev = "2c6191179b82c49584e738baf92d34a84c6a62d6";
    hash = "sha256-oyq7PuGb3X+aEwBC3neVXTl4a05bgjiVaPVfb1egIXs=";
  };

  nativeBuildInputs = [ cmake ];

  # Data only: CMake is used for its install rules, there is nothing to build.
  # (stdenv, not stdenvNoCC: the top-level project() enables C/CXX.)
  dontBuild = true;

  # Upstream installs to the absolute /usr/share/backgrounds.
  postPatch = ''
    substituteInPlace sources/CMakeLists.txt \
      --replace-fail "/usr/share/backgrounds/cutefishos" "share/backgrounds/cutefishos"
  '';

  meta = {
    description = "Wallpapers for the Cutefish desktop";
    homepage = "https://github.com/cutefishos/wallpapers";
    # Unsplash License: free to use and redistribute, but photos may not be
    # resold unmodified nor compiled into a competing service.
    license = lib.licenses.unfreeRedistributable;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
