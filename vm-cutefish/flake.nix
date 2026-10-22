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
              glib # gsettings, to read the settings the session stores
            ];

            # The real thing: cutefish-dm on tty1, the cutefish-wayland session
            # (core supervising cutefish-compositor) on tty2. The module brings
            # the applications, the session entry, the portal and the artwork;
            # all of it needs a working DRM/EGL device, which the VM only gets
            # from the host GPU (see docs/AI-GUIDE.md §9 for how ../vm was
            # verified).
            services.desktopManager.cutefish.enable = true;

            # Keep the login screen: cutefish-dm starts cutefish-compositor
            # --login as cutefish-greeter on VT1, and the session -- the thing
            # worth debugging -- only comes up after you type test/test.
            # Uncomment to skip the greeter and go straight into the session;
            # the module turns this into [Autologin] in /etc/cutefish-dm.conf,
            # and cutefish-dm falls back to the greeter if that login fails.
            # services.displayManager.autoLogin = {
            #   enable = true;
            #   user = "test";
            # };

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
              extraGroups = [
                "wheel"
                "networkmanager"
                "video"
                "render"
                "audio" # PipeWire, which the session starts
              ];
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
