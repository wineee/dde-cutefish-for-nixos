{
  # Mirror of ../vm for Cutefish. Separate flake on purpose: the two VMs need
  # different qemu options and are never debugged at the same time.
  inputs.dde-nixos.url = "..";

  outputs = inputs@{ self, dde-nixos }:
    let
      nixpkgs = dde-nixos.inputs.nixpkgs;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          dde-nixos.nixosModules.cutefish

          ({ config, pkgs, ... }: {
            imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];

            environment.systemPackages = with pkgs; [
              htop
              gdb
              ripgrep
              binutils
              glib # gsettings, used below to pick the icon theme
              # Wayland terminal. sway ships none of its own and its default
              # config references $term, which stays empty unless we set it.
              foot
              wmenu # $mod+d launcher from sway's default config
              # Just to eyeball the icon theme: no Cutefish app is packaged yet.
              thunar
            ];

            # Cutefish artwork (icon theme + wallpapers). The session itself is
            # still missing: cutefish-compositor/cutefish-dm depend on
            # cutefish-toolkit, which needs the pinned Skia build
            # (docs/porting/cutefish-survey.md). Until then sway stands in as a
            # Wayland desktop so the VM is not a bare tty; drop it and enable
            # cutefish-dm + services.displayManager.* once the compositor lands.
            services.desktopManager.cutefish.enable = true;
            programs.sway.enable = true;
            # sway expands variables while parsing, and this file is included at
            # the end of the main config, so the default `bindsym $mod+Return
            # exec $term` has already been expanded to nothing by then: rebind
            # with an absolute path and open a terminal on startup.
            environment.etc."sway/config.d/cutefish.conf".text = ''
              set $term ${pkgs.foot}/bin/foot
              bindsym $mod+Return exec $term
              exec $term
              exec gsettings set org.gnome.desktop.interface icon-theme 'Cutefish'
            '';
            services.greetd = {
              enable = true;
              settings.default_session = {
                # pkgs.sway is only an exec wrapper: it does *not* put the
                # system profile on PATH, so the session would find neither
                # foot nor swaymsg/gsettings. Export it before exec'ing.
                command = let
                  swaySession = pkgs.writeShellScript "sway-vm-session" ''
                    export PATH="${config.system.path}/bin:$PATH"
                    exec ${pkgs.sway}/bin/sway
                  '';
                in "${swaySession}";
                user = "test";
              };
            };
            # Fallback: if sway ever fails to start, tty2+ is already logged in
            # (greetd owns tty1). VM-only convenience.
            services.getty.autologinUser = "test";

            # Wallpapers are unfreeRedistributable (Unsplash License).
            nixpkgs.config.allowUnfree = true;

            # SSH for grabbing boot/session logs from the host. Port differs
            # from ../vm so both VMs can run at once.
            services.openssh = {
              enable = true;
              settings = {
                PermitRootLogin = "no";
                PasswordAuthentication = true;
              };
            };

            time.timeZone = "Asia/Shanghai";

            fonts.packages = with pkgs; [
              noto-fonts
              noto-fonts-cjk-sans
              noto-fonts-color-emoji
            ];

            i18n = {
              defaultLocale = "en_US.UTF-8";
              supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
            };

            users.users.test = {
              isNormalUser = true;
              uid = 1000;
              extraGroups = [ "wheel" "networkmanager" "video" "render" ];
              password = "test";
            };

            virtualisation = {
              forwardPorts = [
                { from = "host"; host.port = 2223; guest.port = 22; }
              ];
              qemu.options = [
                "-vga none"
                "-device virtio-vga-gl"
                "-display gtk,gl=on"
                "-device intel-hda"
                "-device hda-duplex"
              ];
              cores = 8;
              memorySize = 8192;
              diskSize = 16384;
              resolution = { x = 1024; y = 768; };
            };

            system.stateVersion = "26.05";
          })
        ];
      };

      packages.${system}.default = self.nixosConfigurations.vm.config.system.build.vm;
      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/run-nixos-vm";
      };
    };
}
