# dde-nixos

Deepin Desktop Environment (DDE) on NixOS, migrated to Qt6 and running on the
Treeland Wayland compositor.

> 📚 **Docs**
> - [docs/development.md](docs/development.md) — Qt6 upgrade status, maintained
>   packages table, upgrade log, and build gotchas.
> - [docs/AI-GUIDE.md](docs/AI-GUIDE.md) — detailed context for AI agents and
>   future maintainers.
> - [AGENTS.md](AGENTS.md) — quick reference for AI coding agents.

## What is this?

This is a flake that packages DDE for NixOS and progressively migrates it to
Qt6. The package definitions were synced from nixpkgs at the last revision that
still contained them (`96e751adaf2f`), and the NixOS modules from `15a586f29d59`.

Current focus:

- **Qt6 migration** — DTK libraries and core components upgraded to Qt6.
- **Treeland** — the Wayland compositor (QtQuick + vendored waylib/wlroots)
  replaces the removed deepin-kwin/dwayland.
- **DDM** — Deepin Display Manager (SDDM fork) as the login manager.

## Getting Started

### Installation for NixOS (flakes)

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    dde-nixos = {
      url = "github:linuxdeepin/dde-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, dde-nixos, ... } @ inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          dde-nixos.nixosModules.${system}
          {
            services.desktopManager.deepin.enable = true;
            services.displayManager.ddm.enable = true;
          }
          ./configuration.nix # your system configuration goes here
        ];
      };
    };
}
```

> `services.desktopManager.deepin.enable` enables the Treeland Wayland session
> and defaults `services.displayManager.ddm.enable` to true. You can still set
> the DDM option explicitly.

Example: [rewine's NixOS config](https://github.com/wineee/nixos-config/commit/37c70c2c3b2a8e8ee00eba8ea336f67690683de1)

### With `configuration.nix` and flake-compat

```nix
{pkgs, ...}: let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";

  dde-nixos = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/linuxdeepin/dde-nixos/archive/master.tar.gz";
  }).defaultNix;
in {
  imports = [dde-nixos.nixosModules.${pkgs.system}];

  services.desktopManager.deepin.enable = true;
  services.displayManager.ddm.enable = true;

  # other configuration still goes here
}
```

## Testing in QEMU

Quickly start a virtual machine to test (requires nix with flakes enabled):

```bash
git clone git@github.com:linuxdeepin/dde-nixos.git
cd dde-nixos/vm
# edit vm/flake.nix to tweak the VM
nix run -v -L
```

Without custom configuration:

```bash
nix --experimental-features 'nix-command flakes' run "github:linuxdeepin/dde-nixos?dir=vm" -v -L --no-write-lock-file
```

The VM enables DDM + Treeland with a `virtio-vga-gl` display and SSH forwarding
(`host:2222 → guest:22`) for grabbing boot/session logs. See
`docs/AI-GUIDE.md` §9 for the current status and known limits.

## Building packages

```bash
# build a single package
nix build .#deepin-calculator --no-link

# list all exposed packages
nix flake show
```

Manually build for debugging:

```bash
nix develop .#deepin-calculator
git clone git@github.com:linuxdeepin/deepin-calculator.git
git checkout 5.7.16
# ... maintainence code
cmake --build build
```

## Projects using dde-nixos

- [nixos-dde-iso](https://github.com/SamLukeYes/nixos-dde-iso) NixOS live image with DDE [maintainer=@SamLukeYes]
- [dmarked](https://github.com/DMarked/DMarked) dtk based markdown editor

## References

- [DDE Packaging Status](https://github.com/NixOS/nixpkgs/issues/94870)
- [Nix User Repository](https://github.com/nix-community/NUR)
- [nix-cutefish](https://github.com/p3psi-boo/nix-cutefish)
- [budgie-nix](https://github.com/FedericoSchonborn/budgie-nix)

## License

MIT
