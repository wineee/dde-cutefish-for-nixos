{
  lib,
  config,
  pkgs,
}:
let
  packages =
    self:
    let
      inherit (self) callPackage;
    in
    {
      #### LIBRARIES
      # Upgraded and maintained (Qt6):
      dtkcommon = callPackage ./library/dtkcommon { };
      dtkcore = callPackage ./library/dtkcore { };
      dtkgui = callPackage ./library/dtkgui { };
      dtkwidget = callPackage ./library/dtkwidget { };
      dtkdeclarative = callPackage ./library/dtkdeclarative { };
      dtksystemsettings = callPackage ./library/dtksystemsettings { };
      dtklog = callPackage ./library/dtklog { };
      qt6platform-plugins = callPackage ./library/qt6platform-plugins { };
      qt6integration = callPackage ./library/qt6integration { };
      treeland-protocols = callPackage ./library/treeland-protocols { };
      dde-seatd = callPackage ./library/dde-seatd { };

      deepin-pdfium = callPackage ./library/deepin-pdfium { };
      docparser = callPackage ./library/docparser { };
      gio-qt = callPackage ./library/gio-qt { };
      gsettings-qt6 = callPackage ./library/gsettings-qt6 { };
      udisks2-qt6 = callPackage ./library/udisks2-qt6 { };
      qt6mpris = callPackage ./library/qt6mpris { };

      # TODO: upgrade to Qt6 and re-enable
      util-dfm = callPackage ./library/util-dfm { };

      #### CORE
      dde-appearance = callPackage ./core/dde-appearance { };
      dde-app-services = callPackage ./core/dde-app-services { };
      dde-application-manager = callPackage ./core/dde-application-manager { };
      dde-control-center = callPackage ./core/dde-control-center { };
      dde-calendar = callPackage ./core/dde-calendar { };
      dde-clipboard = callPackage ./core/dde-clipboard { };
      dde-file-manager = callPackage ./core/dde-file-manager { };
      dde-launchpad = callPackage ./core/dde-launchpad { };
      dde-network-core = callPackage ./core/dde-network-core { };
      dde-session = callPackage ./core/dde-session { };
      dde-session-shell = callPackage ./core/dde-session-shell { };
      dde-session-ui = callPackage ./core/dde-session-ui { };
      deepin-service-manager = callPackage ./core/deepin-service-manager { };
      dde-polkit-agent = callPackage ./core/dde-polkit-agent { };
      ddm = callPackage ./core/ddm { };
      treeland = callPackage ./core/treeland { };
      dde-gsettings-schemas = callPackage ./core/dde-gsettings-schemas { };
      dde-shell = callPackage ./core/dde-shell { };
      dde-grand-search = callPackage ./core/dde-grand-search { };
      dde-tray-loader = callPackage ./core/dde-tray-loader { };
      deepin-desktop-base = callPackage ./core/deepin-desktop-base { };
      xdg-desktop-portal-dde = callPackage ./core/xdg-desktop-portal-dde { };

      #### Dtk Application
      deepin-calculator = callPackage ./apps/deepin-calculator { };
      deepin-compressor = callPackage ./apps/deepin-compressor { };
      deepin-draw = callPackage ./apps/deepin-draw { };
      deepin-editor = callPackage ./apps/deepin-editor { };
      deepin-music = callPackage ./apps/deepin-music { };
      deepin-picker = callPackage ./apps/deepin-picker { };
      deepin-shortcut-viewer = callPackage ./apps/deepin-shortcut-viewer { };
      deepin-system-monitor = callPackage ./apps/deepin-system-monitor { };
      deepin-terminal = callPackage ./apps/deepin-terminal { };
      deepin-reader = callPackage ./apps/deepin-reader { };
      deepin-screensaver = callPackage ./apps/deepin-screensaver { };

      #### Go Packages
      dde-api = callPackage ./go-package/dde-api { };
      dde-daemon = callPackage ./go-package/dde-daemon { };
      deepin-pw-check = callPackage ./go-package/deepin-pw-check { };
      deepin-desktop-schemas = callPackage ./go-package/deepin-desktop-schemas { };
      startdde = callPackage ./go-package/startdde { };

      #### TOOLS
      dde-device-formatter = callPackage ./tools/dde-device-formatter { };
      deepin-gettext-tools = callPackage ./tools/deepin-gettext-tools { };
      # deepin-anything = callPackage ./tools/deepin-anything { };

      #### ARTWORK
      dde-account-faces = callPackage ./artwork/dde-account-faces { };
      deepin-icon-theme = callPackage ./artwork/deepin-icon-theme { };
      deepin-wallpapers = callPackage ./artwork/deepin-wallpapers { };
      deepin-gtk-theme = callPackage ./artwork/deepin-gtk-theme { };
      deepin-sound-theme = callPackage ./artwork/deepin-sound-theme { };
      deepin-desktop-theme = callPackage ./artwork/deepin-desktop-theme { };
    }
    // lib.optionalAttrs config.allowAliases {
      dpa-ext-gnomekeyring = throw "The 'deepin.dpa-ext-gnomekeyring' package was removed as it is abandoned upstream."; # added 2026-10-09
      dde-qt-dbus-factory = throw "The 'deepin.dde-qt-dbus-factory' package was removed as it is abandoned upstream. Use go-dbus-factory (Go) or dtkcore (Qt6) instead."; # added 2026-10-09
      disomaster = throw "The 'deepin.disomaster' package was removed as it is abandoned upstream."; # added 2026-10-09
      dde-kwin = throw "The 'deepin.dde-kwin' package was removed as it is outdated and no longer relevant. Treeland is the future compositor."; # added 2023-09-27
      dde-widgets = throw "The 'deepin.dde-widgets' package was removed as it is Qt5-only and has no Qt6 migration upstream."; # added 2026-10-09
      dde-launcher = throw "The 'deepin.dde-launcher' is no longer maintained. Please use 'deepin.dde-launchpad' instead."; # added 2023-11-23
      dde-dock = throw "The 'deepin.dde-dock' is no longer maintained. Please use 'deepin.dde-tray-loader' instead."; # added 2024-08-28
      deepin-clone = throw "The 'deepin.deepin-clone' package was removed as it is broken and unmaintained."; # added 2024-08-23
      deepin-turbo = throw "The 'deepin.deepin-turbo' package was removed as it is outdated and no longer relevant."; # added 2024-12-06
      go-lib = throw "Then 'deepin.go-lib' package was removed, use 'go mod' to manage it"; # added 2024-05-31
      go-gir-generator = throw "Then 'deepin.go-gir-generator' package was removed, use 'go mod' to manage it"; # added 2024-05-31
      go-dbus-factory = throw "Then 'deepin.go-dbus-factory' package was removed, use 'go mod' to manage it"; # added 2024-05-31
      deepin-movie-reborn = throw "'deepin.deepin-movie-reborn' has been removed as it was broken and unmaintained in nixpkgs, Please use 'vlc' instead"; # added 2025-01-16;
      deepin-album = throw "'deepin.deepin-album' has been removed as it was broken and unmaintained in nixpkgs, Please use 'kdePackages.gwenview' instead"; # added 2025-01-16
      deepin-voice-note = throw "'deepin.deepin-voice-note' has been removed as it depending on deepin-movie-reborn which was broken"; # added 2025-01-16
      deepin-screen-recorder = throw "'deepin.deepin-screen-recorder' has been removed as it was broken and unmaintained in nixpkgs, Please use 'flameshot' or 'simplescreenrecorder' instead"; # added 2025-01-16
      deepin-ocr-plugin-manager = throw "'deepin.deepin-ocr-plugin-manager' has been removed as it was outdated"; # added 2025-01-16
      deepin-camera = throw "'deepin.deepin-camera' has been removed as it was unmaintained in nixpkgs, Please use 'snapshot' instead"; # added 2025-01-16
      deepin-image-viewer = throw "'deepin.deepin-image-viewer' has been removed as it was broken and unmaintained in nixpkgs, Please use 'kdePackages.gwenview' instead"; # added 2025-01-16
      image-editor = throw "'deepin.image-editor' has been removed as it was unmaintained in nixpkgs"; # added 2025-01-16
    };
in
lib.makeScope pkgs.newScope packages
