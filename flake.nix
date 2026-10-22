{
  description = "deepin desktop environment for nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "i686-linux" ];

      # NixOS modules for the Deepin Desktop Environment, synced from the last
      # nixpkgs revision that still contained them (314fe5f12f46^ = 15a586f29d59):
      #   nixos/modules/services/x11/desktop-managers/deepin.nix
      #   nixos/modules/services/desktops/deepin/{app-services,dde-api,dde-daemon,deepin-anything}.nix
      #
      # The desktop manager module references `pkgs.deepin`, which is provided
      # here through `nixpkgs.overlays` from `./packages`.
      deepinModule =
        { config, lib, pkgs, ... }:
        {
          nixpkgs.overlays = [
            (final: prev: {
              deepin = final.callPackage ./packages { };
            })
          ];

          imports = [
            ./nixos-modules/deepin/deepin.nix
            ./nixos-modules/deepin/app-services.nix
            ./nixos-modules/deepin/dde-api.nix
            ./nixos-modules/deepin/dde-daemon.nix
            ./nixos-modules/deepin/ddm.nix
            ./nixos-modules/deepin/deepin-anything.nix
          ];
        };

      # Cutefish has its own package set (see ./packages/cutefish) and shares
      # nothing with `pkgs.deepin`, so it gets a separate overlay and module.
      cutefishModule =
        { config, lib, pkgs, ... }:
        {
          nixpkgs.overlays = [
            (final: prev: {
              cutefish = import ./packages/cutefish { pkgs = final; };
            })
          ];

          imports = [
            ./nixos-modules/cutefish/cutefish.nix
            ./nixos-modules/cutefish/dm.nix
            ./nixos-modules/cutefish/artwork.nix
          ];
        };
    in
    {
      # Canonical module names, plus per-system aliases for backwards
      # compatibility with the historical `dde-nixos.nixosModules.<system>`
      # (those keep pointing at DDE).
      nixosModules =
        {
          deepin = deepinModule;
          cutefish = cutefishModule;
        }
        // builtins.listToAttrs (
          map (system: {
            name = system;
            value = deepinModule;
          }) systems
        );
    }
    // flake-utils.lib.eachSystem systems
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # DDE package set, synced from nixpkgs `pkgs/desktops/deepin` at the
          # last revision that still contained it (96e751adaf2f). The scope
          # exposes helpers (callPackage/newScope/...) and `throw`-based
          # aliases for removed packages, so only the derivations are exposed
          # as `packages.*`.
          deepin = pkgs.callPackage ./packages { };
          isDerivation = value: (builtins.tryEval (value.type or null)).value == "derivation";
          deepinPackages = pkgs.lib.filterAttrs (_: isDerivation) deepin;

          # Cutefish: its own package set, not part of the DDE scope.
          cutefish = import ./packages/cutefish { inherit pkgs; };
          cutefishPackages = pkgs.lib.filterAttrs (_: isDerivation) cutefish;
        in
        {
          # flake-utils flattens this into packages.<system>.<name>.
          packages = deepinPackages // cutefishPackages;

          # The DDE package scope (pkgs.deepin) expected by the NixOS module.
          legacyPackages.deepin = deepin;
          legacyPackages.cutefish = cutefish;
        });
}
