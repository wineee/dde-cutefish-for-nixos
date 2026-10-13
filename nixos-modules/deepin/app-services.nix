{
  config,
  pkgs,
  lib,
  ...
}:
{

  meta = {
    maintainers = lib.teams.deepin.members;
  };

  ###### interface

  options = {

    services.deepin25.app-services = {

      enable = lib.mkEnableOption "service collection of DDE applications, including dconfig-center";

    };

  };

  ###### implementation

  config = lib.mkIf config.services.deepin25.app-services.enable {

    environment.systemPackages = [ pkgs.deepin.dde-app-services ];
    systemd.packages = [ pkgs.deepin.dde-app-services ];
    services.dbus.packages = [ pkgs.deepin.dde-app-services ];

    environment.pathsToLink = [ "/share/dsg" ];

  };

}
