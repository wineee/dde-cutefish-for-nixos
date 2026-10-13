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

  options = {

    services.deepin25.deepin-anything = {

      enable = lib.mkEnableOption "deepin anything file search tool";

    };

  };

  config = lib.mkIf config.services.deepin25.dde-api.enable {
    environment.systemPackages = [ pkgs.deepin.deepin-anything ];

    services.dbus.packages = [ pkgs.deepin.deepin-anything ];

    users.groups.deepin-anything = { };

    users.users.deepin-anything = {
      description = "Deepin Anything Server";
      home = "/var/lib/deepin-anything";
      createHome = true;
      group = "deepin-anything";
      isSystemUser = true;
    };

    boot.extraModulePackages = [ config.boot.kernelPackages.deepin-anything-module ];
    boot.kernelModules = [ "vfs_monitor" ];
  };

}
