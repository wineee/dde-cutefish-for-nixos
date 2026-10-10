{
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
          dde-nixos.nixosModules.${system}

          {
            imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];

            environment.systemPackages = with pkgs; [
              htop
              gdb
              dconf-editor
              d-spy
              binutils
              ripgrep
            ];

            # Deepin (Treeland Wayland session) + ddm display manager.
            services.desktopManager.deepin.enable = true;
            services.displayManager.ddm.enable = true;

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
              qemu.options = [ "-device intel-hda -device hda-duplex" ];
              cores = 8;
              memorySize = 8192;
              diskSize = 16384;
              resolution = { x = 1024; y = 768; };
            };

            system.stateVersion = "23.11";
          }
        ];
      };

      packages.${system}.default = self.nixosConfigurations.vm.config.system.build.vm;
      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/run-nixos-vm";
      };
    };
}
