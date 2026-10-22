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

    hardware.graphics.enable = lib.mkDefault true;
    security.polkit.enable = true;

    fonts.packages = with pkgs; [ noto-fonts ];
    xdg.mime.enable = true;
    xdg.menus.enable = true;
    xdg.icons.enable = true;

    environment.systemPackages = with pkgs.cutefish; [
      cutefish-calendar
      cutefish-filemanager
      cutefish-settings
      cutefish-system-monitor
      cutefish-terminal
      cutefish-text-editor
      cutefish-video-player
    ];

    # The wayland-sessions entry, the D-Bus system services of the privacy
    # switches, their udev rules and their units all come from the same
    # package, so any display manager can start the session.
    services.displayManager.sessionPackages = [ pkgs.cutefish.cutefish-core ];
    services.dbus.packages = [ pkgs.cutefish.cutefish-core ];
    services.udev.packages = [ pkgs.cutefish.cutefish-core ];
    systemd.packages = [ pkgs.cutefish.cutefish-core ];

    xdg.portal = {
      enable = lib.mkDefault true;
      extraPortals = [ pkgs.cutefish.xdg-desktop-portal-cutefish ];
    };

    # The session sets QT_QPA_PLATFORMTHEME=cutefish; Qt then looks for the
    # theme plugin, which we install outside qtbase, so its directory has to be
    # on QT_PLUGIN_PATH for Qt applications to pick it up.
    environment.variables.QT_PLUGIN_PATH = lib.mkDefault
      "${pkgs.cutefish.cutefish-qt-plugins}/${pkgs.qt6Packages.qtbase.qtPluginPrefix}";

    # cutefish-dm is packaged but not wired up: enabling it means a greeter
    # user, PAM stacks for cutefish-dm and cutefish-dm-greeter, and taking
    # over display-manager.service, which the session options above do not
    # cover yet. See docs/porting/cutefish-survey.md.
  };
}
