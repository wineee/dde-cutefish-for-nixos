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

    # Not wired yet: compositor/display manager are still unpackaged. When they
    # land this module also needs sessionPackages + defaultSession, dbus and
    # systemd.packages for core/compositor/dm, PAM for cutefish-dm, the udev
    # rules and xdg-desktop-portal-cutefish. See docs/porting/cutefish-survey.md.
  };
}
