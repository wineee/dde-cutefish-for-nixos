{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.desktopManager.cutefish;
in
{
  meta = {
    maintainers = with lib.maintainers; [ wineee ];
  };

  ###### interface

  options = {
    services.desktopManager.cutefish = {
      enable = lib.mkEnableOption "Cutefish desktop environment";
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    services.cutefish.artwork.enable = lib.mkDefault true;
    # Declared by dm.nix; defaulted here so that `enable` is all it takes.
    services.desktopManager.cutefish.displayManager.enable = lib.mkDefault true;

    hardware.graphics.enable = lib.mkDefault true;
    security.polkit.enable = true;

    fonts.packages = with pkgs; [ noto-fonts ];
    xdg.mime.enable = true;
    xdg.menus.enable = true;
    xdg.icons.enable = true;

    environment.systemPackages = with pkgs.cutefish; [
      # Not just for its wayland-sessions entry: the session's own commands
      # (cutefish-wayland-session, cutefish-services, cutefish-polkit-agent)
      # have to be on PATH -- the compositor looks the latter two up at
      # runtime, and the login screen executes the first one by name.
      cutefish-core
      cutefish-calendar
      cutefish-filemanager
      cutefish-settings
      cutefish-system-monitor
      cutefish-terminal
      cutefish-text-editor
      cutefish-video-player
    ];

    # cutefish-dm needs to know which entry to start when the user just
    # presses enter; any other display manager reads the same list.
    services.displayManager.defaultSession = lib.mkDefault "cutefish-wayland";

    # The wayland-sessions entry, the D-Bus system services of the privacy
    # switches, their udev rules and their units all come from the same
    # package, so any display manager can start the session.
    services.displayManager.sessionPackages = [ pkgs.cutefish.cutefish-core ];
    services.dbus.packages = [ pkgs.cutefish.cutefish-core ];
    services.udev.packages = [ pkgs.cutefish.cutefish-core ];
    systemd.packages = [ pkgs.cutefish.cutefish-core ];

    xdg.portal = {
      enable = lib.mkDefault true;
      extraPortals = [
        pkgs.cutefish.xdg-desktop-portal-cutefish
        # Ours only implements Settings/FileChooser/Inhibit/ScreenCast.
        pkgs.xdg-desktop-portal-gtk
      ];
      # Since 1.17 the backend is picked explicitly; ours first, then GTK for
      # the interfaces it does not implement.
      config.common.default = lib.mkDefault "cutefish;gtk";
    };

    # The session sets QT_QPA_PLATFORMTHEME=cutefish; Qt then looks for the
    # theme plugin, which we install outside qtbase, so its directory has to be
    # on QT_PLUGIN_PATH for Qt applications to pick it up.
    environment.variables.QT_PLUGIN_PATH = lib.mkDefault
      "${pkgs.cutefish.cutefish-qt-plugins}/${pkgs.qt6Packages.qtbase.qtPluginPrefix}";

    # The compositor's audio client and the screen recorder both talk to
    # PipeWire; without it the session starts with no sound and no capture.
    services.pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
    };
  };
}
