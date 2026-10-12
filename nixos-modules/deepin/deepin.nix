{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let
  cfg = config.services.desktopManager.deepin;

  nixos-gsettings-overrides = pkgs.deepin.dde-gsettings-schemas.override {
    extraGSettingsOverridePackages = cfg.extraGSettingsOverridePackages;
    extraGSettingsOverrides = cfg.extraGSettingsOverrides;
  };
in
{
  options = {

    services.desktopManager.deepin = {
      enable = mkEnableOption "Deepin desktop environment (Treeland Wayland session)";
      extraGSettingsOverrides = mkOption {
        default = "";
        type = types.lines;
        description = "Additional gsettings overrides.";
      };
      extraGSettingsOverridePackages = mkOption {
        default = [ ];
        type = types.listOf types.path;
        description = "List of packages for which gsettings are overridden.";
      };
    };

    environment.deepin.excludePackages = mkOption {
      default = [ ];
      type = types.listOf types.package;
      description = "List of default packages to exclude from the configuration";
    };

  };

  config = mkIf cfg.enable {
    services.displayManager.sessionPackages = [ pkgs.deepin.treeland ];
    services.displayManager.defaultSession = mkDefault "treeland";

    # Wayland/Treeland display manager (fork of SDDM) and its seat daemon.
    services.displayManager.ddm.enable = mkDefault true;

    hardware.bluetooth.enable = mkDefault true;
    security.polkit.enable = true;

    # Treeland is a Wayland compositor backed by wlroots; it needs a GL
    # stack and Xwayland for X11 clients.
    hardware.graphics.enable = mkDefault true;
    programs.xwayland.enable = mkDefault true;

    services.deepin25.dde-daemon.enable = mkForce true;
    services.deepin25.dde-api.enable = mkForce true;
    services.deepin25.app-services.enable = mkForce true;

    services.colord.enable = mkDefault true;
    services.accounts-daemon.enable = mkDefault true;
    services.gvfs.enable = mkDefault true;
    services.gnome.glib-networking.enable = mkDefault true;
    services.gnome.gnome-keyring.enable = mkDefault true;
    services.gnome.gcr-ssh-agent.enable = mkDefault true;
    services.bamf.enable = mkDefault true;

    services.libinput.enable = mkDefault true;
    services.udisks2.enable = true;
    services.upower.enable = mkDefault config.powerManagement.enable;
    networking.networkmanager.enable = mkDefault true;
    programs.dconf.enable = mkDefault true;
    programs.gnupg.agent.pinentryPackage = mkDefault pkgs.pinentry-qt;

    fonts.packages = with pkgs; [ noto-fonts ];
    xdg.mime.enable = true;
    xdg.menus.enable = true;
    xdg.icons.enable = true;
    xdg.portal.enable = mkDefault true;
    xdg.portal.extraPortals = mkDefault [
      pkgs.deepin.xdg-desktop-portal-dde
      pkgs.xdg-desktop-portal-gtk
    ];

    # XDG_CURRENT_DESKTOP is set to "DDE" by dde-session (see
    # environmentsmanager.cpp), so the portal configuration must be keyed
    # under "dde" to be picked up as dde-portals.conf. Prefer the DDE
    # backend and fall back to gtk for the interfaces it does not provide
    # (AppChooser, Print, ...).
    xdg.portal.config.dde.default = mkDefault [ "dde" "gtk" ];

    environment.sessionVariables = {
      NIX_GSETTINGS_OVERRIDES_DIR = "${nixos-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";
    };

    environment.pathsToLink = [
      "/lib/dde-dock/plugins"
      "/lib/dde-control-center"
      "/lib/dde-session-shell"
      "/lib/dde-file-manager"
      "/share/backgrounds"
      "/share/wallpapers"
      "/share/dde-daemon"
      "/share/dsg"
      "/share/deepin-themes"
      "/share/deepin"
      "/share/dde-shell"
    ];

    environment.etc = {
      "deepin-installer.conf".text = ''
        system_info_vendor_name="Copyright (c) 2003-2024 NixOS contributors"
      '';
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/AccountsService 0775 root root - -"
      "C /var/lib/AccountsService/icons 0775 root root - ${pkgs.deepin.dde-account-faces}/var/lib/AccountsService/icons"
    ];

    security.pam.services.dde-lock.text = ''
      # original at {dde-session-shell}/etc/pam.d/dde-lock
      auth      substack      login
      account   include       login
      password  substack      login
      session   include       login
    '';

    environment.systemPackages =
      with pkgs;
      with deepin;
      let
        requiredPackages = [
          pciutils # for dtkcore/startdde
          xdotool # for dde-daemon
          glib # for gsettings program / gdbus
          gtk3 # for gtk-launch program
          xdg-user-dirs # Update user dirs
          util-linux # runuser
          polkit_gnome
          librsvg # dde-api use rsvg-convert
          lshw # for dtkcore
          xsettingsd # lightdm-deepin-greeter
          dtkcommon
          dtkcore
          dtkgui
          dtkwidget
          dtkdeclarative
          qt6platform-plugins
          qt6integration
          deepin-pw-check

          dde-account-faces
          deepin-icon-theme
          deepin-desktop-theme
          deepin-sound-theme
          deepin-gtk-theme
          deepin-wallpapers
          deepin-desktop-base

          startdde
          dde-shell
          dde-launchpad
          dde-session-ui
          dde-session-shell
          dde-file-manager
          dde-control-center
          dde-network-core
          dde-clipboard
          dde-polkit-agent
          deepin-desktop-schemas
          dde-session
          dde-appearance
          dde-application-manager
          deepin-service-manager
          dde-tray-loader
        ];
        optionalPackages = [
          dde-calendar
          dde-grand-search
          deepin-terminal
          onboard # dde-dock plugin
          deepin-calculator
          deepin-compressor
          deepin-editor
          deepin-system-monitor
          deepin-shortcut-viewer
        ];
      in
      requiredPackages
      ++ utils.removePackagesByName optionalPackages config.environment.deepin.excludePackages;

    services.dbus.packages = with pkgs.deepin; [
      treeland
      dde-shell
      dde-launchpad
      dde-session-ui
      dde-session-shell
      dde-file-manager
      dde-control-center
      dde-calendar
      dde-clipboard
      deepin-pw-check
      dde-session
      dde-appearance
      dde-application-manager
      deepin-service-manager
      dde-grand-search
    ];

    systemd.packages = with pkgs.deepin; [
      treeland
      dde-shell
      dde-launchpad
      dde-file-manager
      dde-calendar
      dde-clipboard
      dde-appearance
      dde-session
      dde-application-manager
      deepin-service-manager
    ];
  };
}
