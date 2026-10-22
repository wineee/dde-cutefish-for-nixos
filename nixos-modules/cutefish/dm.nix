{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.desktopManager.cutefish.displayManager;
  dmcfg = config.services.displayManager;

  iniFmt = pkgs.formats.ini { };

  # Hardcoded in daemon/config.h, and the user the login screen drops to.
  greeterUser = "cutefish-greeter";

  defaultConfig = {
    # The session list is whatever the desktop module installs, and the login
    # screen picks the first one; name ours so it does not depend on ordering.
    Session.Default = "cutefish-wayland";
    # `services.displayManager.sessionPackages` is not on the system profile:
    # it builds sessionData.desktops, and only its `share` lands in
    # XDG_DATA_DIRS. The package's own compiled-in default (/run/current-system)
    # is therefore empty, so point the daemon at the sessions it was given.
    Session.Directories = "${dmcfg.sessionData.desktops}/share/wayland-sessions";
  }
  // lib.optionalAttrs dmcfg.autoLogin.enable {
    # Unlike ddm, cutefish-dm matches session ids without the .desktop suffix.
    Autologin = {
      User = dmcfg.autoLogin.user;
      Session = dmcfg.sessionData.autologinSession;
    };
  };

  cfgFile = iniFmt.generate "cutefish-dm.conf" (lib.recursiveUpdate defaultConfig cfg.settings);

  # data/no-greeter-audio.conf, installed once per unit upstream.
  userDropIns = builtins.readDir "${cfg.package}/share/systemd/user";
in
{
  options.services.desktopManager.cutefish.displayManager = {
    enable = lib.mkEnableOption "cutefish-dm, the display manager of the Cutefish desktop";

    package = lib.mkPackageOption pkgs.cutefish [ "cutefish-dm" ] { };

    settings = lib.mkOption {
      type = iniFmt.type;
      default = { };
      description = ''
        Extra settings merged in and overwriting the defaults of
        `cutefish-dm.conf`.

        Keys are the ones `daemon/config.cpp` reads: `Greeter`
        (`Vt`/`User`/`Command`/`Service`), `Session`
        (`Vt`/`Service`/`Directories`/`Default`), `Autologin`
        (`User`/`Session`) and `Daemon` (`RuntimeDirectory`/`StatePath`).
      '';
      example = {
        Autologin = {
          User = "john";
          Session = "cutefish-wayland";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = dmcfg.autoLogin.enable -> dmcfg.sessionData.autologinSession != null;
        message = ''
          cutefish-dm auto-login requires `services.displayManager.defaultSession`
          to be set (or at least one session package to be installed).
        '';
      }
    ];

    services.displayManager.enable = true;

    # `services.xserver.enable = true` makes lightdm the fallback display
    # manager when no other DM is selected. cutefish-dm is mutually exclusive
    # with it, so force it off.
    services.xserver.displayManager.lightdm.enable = lib.mkForce false;

    environment.systemPackages = [ cfg.package ];

    # The daemon owns org.cutefish.DisplayManager on the system bus; without
    # its policy file the bus refuses the name.
    services.dbus.packages = [ cfg.package ];

    # Mounts cutefish-dm.service, which carries the plymouth/getty conflicts
    # and `Restart=always`.
    systemd.packages = [ cfg.package ];

    systemd.services.cutefish-dm = {
      # Upstream ships `[Install] Alias=display-manager.service`, but NixOS
      # does not process [Install] sections. graphical.target carries
      # `Wants=display-manager.service`, so aliasing is what pulls it in.
      aliases = [ "display-manager.service" ];
      wantedBy = [ "graphical.target" ];
      # Don't kill a running login screen or session on nixos-rebuild switch.
      restartIfChanged = false;
      # The linked unit gets no PATH of its own, and the compositor looks its
      # session companions (cutefish-services, cutefish-polkit-agent) up on
      # PATH at runtime.
      path = [ config.system.path ];
    };

    systemd.tmpfiles.rules = [
      # state.conf and the login screen's backgrounds.
      "d /var/lib/cutefish-dm 0750 ${greeterUser} ${greeterUser} - -"
      # The greeter socket, owned by the daemon and reachable by the greeter.
      "d /run/cutefish-dm 0711 root root - -"
    ];

    users.groups.${greeterUser} = { };
    users.users.${greeterUser} = {
      description = "Cutefish login screen account";
      isSystemUser = true;
      group = greeterUser;
      home = "/var/lib/cutefish-dm";
      # The login screen is the compositor, so it needs the DRM devices.
      extraGroups = [
        "video"
        "render"
      ];
    };

    # Upstream ships Debian stacks that `@include common-*`, which NixOS has
    # no equivalent of; `login` is what those expand to here. It also carries
    # pam_systemd.so, which is what gives the session its logind seat and its
    # systemd --user instance.
    # (`startSession` would add the same module, but it is ignored when `text`
    # is set, so the pam_systemd.so line below is written out instead.)
    security.pam.services.cutefish-dm.text = ''
      auth       requisite     pam_nologin.so
      auth       required      pam_succeed_if.so user != root quiet_success
      auth       substack      login
      account    include       login
      password   substack      login
      session    include       login
    '';

    # The login screen is started unauthenticated, as its own system user --
    # but it *is* the compositor, so it needs a seat and an XDG_RUNTIME_DIR
    # of its own, hence pam_systemd.
    security.pam.services.cutefish-dm-greeter.text = ''
      auth       required      pam_permit.so
      account    required      pam_permit.so
      password   required      pam_deny.so
      session    required      pam_limits.so
      session    required      pam_loginuid.so
      -session   optional      ${pkgs.systemd}/lib/security/pam_systemd.so
      session    required      pam_env.so
    '';

    environment.etc = lib.mkMerge (
      [
        { "cutefish-dm.conf".source = cfgFile; }
      ]
      # Those drop-ins silence PipeWire on the login screen, so it does not set
      # the shared ALSA mixer volume the user's session then adopts. Upstream
      # installs them under /usr/lib/systemd/user, which NixOS does not read;
      # /etc/systemd/user is where the user instance looks.
      ++ lib.mapAttrsToList
        (unit: _: {
          "systemd/user/${unit}/cutefish-dm.conf".source =
            "${cfg.package}/share/systemd/user/${unit}/cutefish-dm.conf";
        })
        userDropIns
    );
  };
}
