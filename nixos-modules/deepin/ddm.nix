{
  config,
  lib,
  pkgs,
  ...
}:

let
  dmcfg = config.services.displayManager;
  cfg = config.services.displayManager.ddm;

  iniFmt = pkgs.formats.ini { };

  defaultConfig =
    {
      General = {
        HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
        RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
      };

      Wayland = {
        SessionDir = "${dmcfg.sessionData.desktops}/share/wayland-sessions";
      };
    }
    // lib.optionalAttrs dmcfg.autoLogin.enable {
      Autologin = {
        User = dmcfg.autoLogin.user;
        Session = "${dmcfg.sessionData.autologinSession}.desktop";
      };
    };

  cfgFile = iniFmt.generate "ddm.conf" (lib.recursiveUpdate defaultConfig cfg.settings);
in
{
  options.services.displayManager.ddm = {
    enable = lib.mkEnableOption "ddm, a fork of SDDM used as the Deepin display manager";

    package = lib.mkPackageOption pkgs.deepin [ "ddm" ] { };

    settings = lib.mkOption {
      type = iniFmt.type;
      default = { };
      description = ''
        Extra settings merged in and overwriting defaults in `ddm.conf`.

        See {manpage}`ddm.conf(5)` for the supported sections
        (`General`, `Theme`, `X11`, `Wayland`, `Single`, `Users`,
        `Autologin`).
      '';
      example = {
        Autologin = {
          User = "john";
          Session = "treeland.desktop";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = dmcfg.autoLogin.enable -> dmcfg.sessionData.autologinSession != null;
        message = ''
          ddm auto-login requires `services.displayManager.defaultSession` to be
          set (or at least one session package to be installed).
        '';
      }
    ];

    services.displayManager.enable = true;

    # `services.xserver.enable = true` makes lightdm the fallback display
    # manager when no other DM is selected. ddm is a mutually exclusive
    # display manager, so force it off to avoid the two execCmds colliding.
    services.xserver.displayManager.lightdm.enable = lib.mkForce false;

    environment.systemPackages = [ cfg.package ];

    # ddm owns both org.freedesktop.DisplayManager and
    # org.deepin.DisplayManager on the system bus; without its policy files
    # the D-Bus daemon refuses the NameOwnerChanged for those names.
    services.dbus.packages = [ cfg.package ];

    # The generated ddm.conf is read-only; ddm never rewrites it (it stores
    # runtime state in state.conf under the ddm user's home directory).
    environment.etc."ddm.conf.d/00-nixos.conf".source = cfgFile;

    # Mount the upstream units (ddm.service + dde-seatd.service) instead of
    # the deprecated generic display-manager integration. The upstream unit
    # carries the hardening (CapabilityBoundingSet/PrivateIPC/ProtectClock),
    # `Requires=dde-seatd.service`, and the VT7 getty conflicts.
    systemd.packages = [
      cfg.package
      pkgs.deepin.dde-seatd.out
    ];

    systemd.services.ddm = {
      # Upstream ships `[Install] Alias=display-manager.service`, but NixOS
      # does not process [Install] sections. graphical.target carries
      # `Wants=display-manager.service`, so aliasing is what pulls ddm in.
      aliases = [ "display-manager.service" ];
      wantedBy = [ "graphical.target" ];
      # Don't kill a running greeter/session on nixos-rebuild switch.
      restartIfChanged = false;
    };

    # The dde-seatd package ships a hardened unit with
    # WantedBy=multi-user.target, but NixOS does not process [Install]
    # sections, so express that explicitly.
    systemd.services.dde-seatd.wantedBy = [ "multi-user.target" ];

    systemd.tmpfiles.rules = [
      # Home of the greeter (dde) and ddm state (state.conf) accounts.
      "d /var/lib/ddm 0750 dde dde - -"
      # X11 auth files passed to Xorg and the greeter.
      "d /run/ddm 0711 root root - -"
    ];

    users.groups.dde = { };
    users.groups.nopasswdlogin = { };

    # Upstream sysusers only creates the `dde` greeter account (and the
    # `nopasswdlogin` group); there is no `ddm` user. `getpwnam("ddm")` in
    # Configuration.h intentionally misses and falls back to STATE_DIR
    # (/var/lib/ddm), which the tmpfiles rule below creates and dde owns.
    users.users.dde = {
      description = "DDM greeter account";
      isSystemUser = true;
      group = "dde";
      home = "/var/lib/ddm";
      # treeland runs as this user and needs access to DRM devices.
      extraGroups = [
        "video"
        "render"
      ];
    };

    security.pam.services.ddm.text = ''
      # Allow members of the nopasswdlogin group to log in without a password
      auth       sufficient    pam_succeed_if.so user ingroup nopasswdlogin
      auth       substack      login
      account    include       login
      password   substack      login
      session    include       login
    '';

    security.pam.services.ddm-autologin.text = ''
      auth       requisite     pam_nologin.so
      auth       required      pam_succeed_if.so uid >= 1000 quiet
      auth       required      pam_permit.so
      account    include       ddm
      password   include       ddm
      session    include       ddm
    '';
  };
}
