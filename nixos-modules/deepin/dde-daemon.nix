{
  config,
  pkgs,
  lib,
  ...
}:
{

  meta = {
    maintainers = with lib.maintainers; [ wineee ];
  };

  ###### interface

  options = {

    services.deepin25.dde-daemon = {

      enable = lib.mkEnableOption "daemon for handling the deepin session settings";

    };

  };

  ###### implementation

  config = lib.mkIf config.services.deepin25.dde-daemon.enable {

    environment.systemPackages = [ pkgs.deepin.dde-daemon ];

    services.dbus.packages = [ pkgs.deepin.dde-daemon ];

    systemd.packages = [ pkgs.deepin.dde-daemon ];

    environment.pathsToLink = [ "/lib/deepin-daemon" ];

    # Upstream dde-daemon sysusers (dde-daemon.conf) creates these accounts;
    # the shipped systemd units (dde-dconfig-daemon, deepin-*-sound, ...)
    # run as deepin-daemon / deepin-admin-daemon.
    users.groups.deepin-daemon = { };
    users.users.deepin-daemon = {
      description = "DDE daemon account";
      isSystemUser = true;
      group = "deepin-daemon";
      extraGroups = [ "netdev" ];
    };
    users.groups.deepin-admin-daemon = { };
    users.users.deepin-admin-daemon = {
      description = "DDE admin daemon account";
      isSystemUser = true;
      group = "deepin-admin-daemon";
    };

  };

}
