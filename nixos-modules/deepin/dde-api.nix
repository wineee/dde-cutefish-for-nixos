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

    services.deepin25.dde-api = {

      enable = lib.mkEnableOption ''
        the DDE API, which provides some dbus interfaces that is used for screen zone detecting,
        thumbnail generating, and sound playing in Deepin Desktop Environment
      '';

    };

  };

  ###### implementation

  config = lib.mkIf config.services.deepin25.dde-api.enable {

    environment.systemPackages = [ pkgs.deepin.dde-api ];

    services.dbus.packages = [ pkgs.deepin.dde-api ];

    systemd.packages = [ pkgs.deepin.dde-api ];

    environment.pathsToLink = [ "/lib/deepin-api" ];

    users.groups.deepin-sound-player = { };
    users.users.deepin-sound-player = {
      description = "Deepin sound player";
      home = "/var/lib/deepin-sound-player";
      createHome = true;
      group = "deepin-sound-player";
      isSystemUser = true;
    };

  };

}
