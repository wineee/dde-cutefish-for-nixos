# dde-cutefish-for-nixos

Two experimental desktop ports for NixOS: **DDE** (Deepin Desktop Environment,
Qt6 + Treeland) and **Cutefish**. This README is only a signpost — pick one and
read its documentation.

> [!WARNING]
> **Experimental — please read before using.**
>
> - **The DDE port is still in progress and is not usable.** Enabling
>   `services.desktopManager.deepin` does not give you a working desktop yet.
>   It is a porting workbench, not a daily driver.
> - **This repository is maintained with heavy AI assistance.** Package
>   definitions, patches, NixOS modules and docs are largely produced by coding
>   agents. They are **not guaranteed** to meet the standards nixpkgs requires
>   for merge, and are not meant to be upstreamed as-is. See
>   [docs/upstream-patches.md](docs/upstream-patches.md).
> - The Cutefish port is experimental too: all 17 packages build and the VM
>   image builds, but booting it on real hardware is unverified.

| | DDE | Cutefish |
|---|---|---|
| Enable | `services.desktopManager.deepin.enable` | `services.desktopManager.cutefish.enable` |
| Status | porting in progress, **not usable** | packages + VM image build; real-hardware boot untested |
| Start here | [docs/development.md](docs/development.md) | [docs/porting/cutefish-survey.md](docs/porting/cutefish-survey.md) |

## DDE

Status: **in progress, not usable.** See
[docs/development.md](docs/development.md) for the maintained-package table, the
Qt6 upgrade log and the build gotchas; [docs/AI-GUIDE.md](docs/AI-GUIDE.md) §9
for how the VM was verified on real hardware and what still fails;
`docs/porting/dde-*.md` for per-package notes.

```bash
cd vm && nix run -v -L      # DDM + Treeland VM
```

## Cutefish

Status: 17 packages and the VM image build; **booting it has not been verified**
(it needs the host GPU's DRM/EGL). `services.desktopManager.cutefish.enable`
brings in the session, `cutefish-dm`, the portal and the artwork in one go.

Read [docs/porting/cutefish-survey.md](docs/porting/cutefish-survey.md)
(overview and progress), then
[cutefish-toolkit.md](docs/porting/cutefish-toolkit.md) (Skia + toolkit),
[cutefish-core.md](docs/porting/cutefish-core.md) (session, background
services, display manager) and
[cutefish-apps.md](docs/porting/cutefish-apps.md) (applications).

```bash
cd vm-cutefish
nix build --no-write-lock-file --impure && ./result/bin/run-nixos-vm
```

## Using this flake

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    dde-cutefish-for-nixos = {
      url = "github:wineee/dde-cutefish-for-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, dde-cutefish-for-nixos, ... }:
    let system = "x86_64-linux";
    in {
      nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          dde-cutefish-for-nixos.nixosModules.${system}
          {
            # one of the two:
            services.desktopManager.deepin.enable = true;    # unusable, see docs
            services.desktopManager.cutefish.enable = true;  # brings cutefish-dm
          }
          ./configuration.nix
        ];
      };
    };
}
```

Non-flake setups go through `flake-compat` with
`https://github.com/wineee/dde-cutefish-for-nixos/archive/master.tar.gz`.

## Building packages

```bash
nix build .#<package> --no-link   # single package
nix flake show                    # everything exposed
```

## Projects using this

- [nixos-dde-iso](https://github.com/SamLukeYes/nixos-dde-iso) — NixOS live image with DDE [maintainer=@SamLukeYes]
- [dmarked](https://github.com/DMarked/DMarked) — DTK based markdown editor

## References

- [DDE Packaging Status](https://github.com/NixOS/nixpkgs/issues/94870)
- [Nix User Repository](https://github.com/nix-community/NUR)
- [nix-cutefish](https://github.com/p3psi-boo/nix-cutefish)
- [budgie-nix](https://github.com/FedericoSchonborn/budgie-nix)

## License

MIT
