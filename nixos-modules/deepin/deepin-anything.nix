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

  config = lib.mkIf config.services.deepin25.deepin-anything.enable {
    environment.systemPackages = [ pkgs.deepin.deepin-anything ];

    # The package ships the logger (system) and daemon (user) units; the server
    # unit upstream leaves to the packager, so declare it here. The daemon is a
    # per-user search service and must be started for each logged-in user.
    systemd.packages = [ pkgs.deepin.deepin-anything ];

    systemd.services.deepin-anything-server = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "root";
        Group = "root";
        ExecStart = "${pkgs.deepin.deepin-anything}/libexec/deepin-anything-server";
        ExecStartPre = "-${pkgs.kmod}/bin/modprobe vfs_monitor";
        ExecStopPost = "-${pkgs.kmod}/bin/rmmod vfs_monitor";
        RuntimeDirectory = "deepin-anything";
        Restart = "always";
        RestartSec = 30;
      };
    };

    systemd.services.deepin-anything-logger = {
      wantedBy = [ "multi-user.target" ];
    };

    systemd.user.services.deepin-anything-daemon.wantedBy = [ "default.target" ];

    # vfs_monitor.ko must be built against the kernel it will be loaded into.
    boot.extraModulePackages = [
      (config.boot.kernelPackages.callPackage
        ../../packages/tools/deepin-anything-module { })
    ];
    boot.kernelModules = [ "vfs_monitor" ];
  };

}
