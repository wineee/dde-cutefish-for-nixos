{ pkgs }:
# Cutefish package set.
#
# Kept separate from the DDE scope in ../default.nix: Cutefish is not Qt/DTK
# based (its toolkit draws with Skia on GLES) and nothing in the DDE module
# refers to it, so it is a plain attribute set fixed over itself instead of a
# lib.makeScope.
#
# Upstream (github.com/cutefishos) publishes no tags; every package is pinned
# to a commit. toolkit/framework/compositor/core speak private Wayland
# protocols and must be bumped together. See docs/porting/cutefish-survey.md.
pkgs.lib.fix (self: {
  cutefish-wallpapers = pkgs.callPackage ./wallpapers { };
  cutefish-icons = pkgs.callPackage ./icons { };

  # Remaining upstream repos, in the order they have to be packaged:
  #   cutefish-toolkit (pinned Skia build, the real blocker)
  #   -> cutefish-framework -> cutefish-compositor / cutefish-core / cutefish-dm
  #   -> filemanager / settings / terminal / ... -> xdg-desktop-portal-cutefish
  #   -> cutefish-qt-plugins, cutefish-computer-use
  # cutefish-installer is not needed on NixOS.
})
