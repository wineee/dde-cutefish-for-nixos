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

  # Pinned Skia; cutefish-toolkit links it as static libraries.
  cutefish-skia = pkgs.callPackage ./skia { };

  cutefish-toolkit = pkgs.callPackage ./toolkit {
    inherit (self) cutefish-skia;
  };

  cutefish-framework = pkgs.callPackage ./framework {
    inherit (self) cutefish-toolkit;
  };

  cutefish-compositor = pkgs.callPackage ./compositor {
    inherit (self) cutefish-toolkit cutefish-framework;
  };

  # Applications; every one of them does find_package(CutefishToolkit).
  cutefish-text-editor = pkgs.callPackage ./text-editor {
    inherit (self) cutefish-toolkit;
  };
  cutefish-terminal = pkgs.callPackage ./terminal {
    inherit (self) cutefish-toolkit;
  };
  cutefish-filemanager = pkgs.callPackage ./filemanager {
    inherit (self) cutefish-toolkit cutefish-framework;
  };
  cutefish-settings = pkgs.callPackage ./settings {
    inherit (self) cutefish-toolkit cutefish-framework;
  };
  cutefish-calendar = pkgs.callPackage ./calendar {
    inherit (self) cutefish-toolkit;
  };
  cutefish-video-player = pkgs.callPackage ./video-player {
    inherit (self) cutefish-toolkit;
  };
  cutefish-system-monitor = pkgs.callPackage ./system-monitor {
    inherit (self) cutefish-toolkit;
  };
  xdg-desktop-portal-cutefish = pkgs.callPackage ./portal {
    inherit (self) cutefish-toolkit;
  };

  # Session and background services. Runs the compositor, so it depends on it.
  cutefish-core = pkgs.callPackage ./core {
    inherit (self) cutefish-toolkit cutefish-framework cutefish-compositor;
  };

  # Qt/Papyrus integration for third-party Qt applications.
  cutefish-qt-plugins = pkgs.callPackage ./qt-plugins { };

  # Display manager: the login screen is the compositor itself.
  cutefish-dm = pkgs.callPackage ./dm {
    inherit (self) cutefish-toolkit cutefish-compositor;
  };

  # Remaining upstream repos, in the order they have to be packaged:
  #   cutefish-toolkit (pinned Skia build, the real blocker)
  #   -> cutefish-framework -> cutefish-compositor / cutefish-core / cutefish-dm
  #   -> filemanager / settings / terminal / ... -> xdg-desktop-portal-cutefish
  #   -> cutefish-qt-plugins, cutefish-computer-use
  # cutefish-installer is not needed on NixOS.
})
