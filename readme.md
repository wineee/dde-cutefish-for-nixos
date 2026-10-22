# dde-cutefish-for-nixos

Deepin Desktop Environment (DDE) on NixOS, migrated to Qt6 and running on the
Treeland Wayland compositor — plus an experimental Cutefish desktop port.

> [!WARNING]
> **Experimental — please read before using.**
>
> - **The DDE port is still in progress and is not usable.** Enabling
>   `services.desktopManager.deepin` does not give you a working desktop yet;
>   components are missing or broken. It is a porting workbench, not a daily
>   driver.
> - **This repository is maintained with heavy AI assistance.** Package
>   definitions, patches, NixOS modules and docs are largely produced by coding
>   agents. They are **not guaranteed** to meet the standards nixpkgs requires
>   for merge (review depth, `meta` correctness, licensing, upstreamability),
>   and are not meant to be upstreamed as-is — treat everything here as a
>   starting point that still needs human review. See
>   [docs/upstream-patches.md](docs/upstream-patches.md) for how the current
>   patches split into "real upstream bug" vs "Nix packaging workaround".
> - The Cutefish port is experimental too: all 17 packages build and the VM
>   image builds, but booting it on real hardware is unverified.

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
- **Cutefish** — a second, independent desktop port (`services.desktopManager
  .cutefish.enable`), see [docs/porting/cutefish-survey.md](docs/porting/cutefish-survey.md).

## Getting Started

### Installation for NixOS (flakes)

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    dde-cutefish-for-nixos = {
      url = "github:wineee/dde-cutefish-for-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, dde-cutefish-for-nixos, ... } @ inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          dde-cutefish-for-nixos.nixosModules.${system}
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

  dde-cutefish-for-nixos = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/wineee/dde-cutefish-for-nixos/archive/master.tar.gz";
  }).defaultNix;
in {
  imports = [dde-cutefish-for-nixos.nixosModules.${pkgs.system}];

  services.desktopManager.deepin.enable = true;
  services.displayManager.ddm.enable = true;

  # other configuration still goes here
}
```

## Testing in QEMU

Quickly start a virtual machine to test (requires nix with flakes enabled):

```bash
git clone git@github.com:wineee/dde-cutefish-for-nixos.git
cd dde-cutefish-for-nixos/vm
# edit vm/flake.nix to tweak the VM
nix run -v -L
```

Without custom configuration:

```bash
nix --experimental-features 'nix-command flakes' run "github:wineee/dde-cutefish-for-nixos?dir=vm" -v -L --no-write-lock-file
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

## Projects using dde-cutefish-for-nixos

- [nixos-dde-iso](https://github.com/SamLukeYes/nixos-dde-iso) NixOS live image with DDE [maintainer=@SamLukeYes]
- [dmarked](https://github.com/DMarked/DMarked) dtk based markdown editor

## References

- [DDE Packaging Status](https://github.com/NixOS/nixpkgs/issues/94870)
- [Nix User Repository](https://github.com/nix-community/NUR)
- [nix-cutefish](https://github.com/p3psi-boo/nix-cutefish)
- [budgie-nix](https://github.com/FedericoSchonborn/budgie-nix)

## License

MIT
