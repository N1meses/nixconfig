# nixconfig

Personal NixOS (+ finix) configuration - flakeless: `evalModules` over `modules/`,
inputs pinned by [tack](.tack/), built with `nixos-rebuild --file . --attr`. Home
is managed by [hjem](https://github.com/feel-co/hjem) + hjem-rum (not home-manager).

## Structure

```
nixconfig/
├── default.nix            # Entry point - evalModules over modules/ (tack-pinned inputs)
├── flake.nix              # thin wrapper re-exporting default.nix; NOT a second source of truth
├── shell.nix              # `nix-shell` → the same devShell the flake exposes
├── scripts/drvdiff.sh     # what moved since <ref>, by drvPath
├── .tack/                 # input pins (pins.toml + pins.lock.json) + resolver
├── modules/
│   ├── features/          # every aspect, mirroring the dotted names - MODULES.md lists them
│   ├── hosts/             # Per-host registry entries + `_`-prefixed machine modules
│   ├── users/             # Per-user registry entries (their own aspects list)
│   ├── options/           # schema - registry, aspects, fleet, outputs, compositor options
│   └── builders/          # one file per output in the table below
└── modules/MODULES.md     # Full module reference - GENERATED, see below
```

`default.nix` collects every `.nix` under `modules/` automatically - no manual imports
needed when adding new modules. Files whose name starts with `_` are skipped: that is
how per-host machine modules (`_hardware.nix`, `_disko.nix`, `_devices.nix`) stay out of
the top-level eval and get referenced explicitly from `machineModules` instead.

`default.nix` takes one optional argument, `rev`, which every `--file .` entry point
auto-calls with its default; only `flake.nix` passes it, for the reason under
[Flake wrapper](#flake-wrapper). The one place the auto-call does *not* happen is
`nix eval --apply` without an attribute path - there, import it yourself:
`nix eval --impure --expr '(import ./. { })' --apply f`.

## Outputs

Everything the config produces, from either entry point. Each is built by one file
in `modules/builders/`, and every one is declared with a description in
`modules/options/outputs.nix`.

| Output | What it is |
|---|---|
| `nixosConfigurations.<host>` | a NixOS system |
| `finixConfigurations.<host>` | a finix system (finit as pid 1) |
| `homeConfigurations.<host>.<user>` | standalone hjem manifest + packages |
| `checks.<name>` | `nixos-*` / `finix-*` closures, `hjem-*` dotfile validation, `docs` drift |
| `packages.<name>` | `docs`, and `vm-<host>` finix test VMs |
| `images.<host>.<format>` | 26 disk/container image formats per NixOS host |
| `containers.<name>` | application container images (`podman load`) |
| `deploy.nodes.<host>` | deploy-rs targets, rollback-safe |
| `devShells.<system>.default` | the maintenance shell (`nix-shell` / `nix develop`) |
| `diskoConfigurations.<host>` | disk layout for the disko CLI |
| `resolved.<host>` | introspection: what this host's aspects resolved to |

`aspects`, `registry`, `fleet` and `aspectLib` are also top-level, but they are the
schema and its helpers rather than things you build.

**Image-only hosts.** A host with `machineModules = [ ]` declares no machine, so it
has no root filesystem and no bootloader and `system.build.toplevel` cannot evaluate
by design. Those hosts are excluded from `checks` and from `deploy.nodes`
automatically, and exist only as `images.<host>.<format>` where the format supplies
both. They are marked *(image-only)* in the generated host table.

---

## First-time Installation

### 1. Clone and scaffold the host

```bash
git clone https://github.com/N1meses/nixconfig && cd nixconfig
./modules/hosts/new-host.sh <hostname> [nixos|finix]
```

Writes `modules/hosts/<hostname>/{_hardware.nix,<hostname>.nix}` and
`modules/users/<hostname>.nix`. Run on the target machine and the hardware config is
generated from it; run anywhere else and you get a placeholder to fill in. CI runs
this script on every push and fails if the host it produces stops evaluating, so it
cannot drift away from the schema.

Then edit the generated `<hostname>.nix`. It is a single `registry.hosts.<hostname>`
entry; only `users`, `system` and `stateVersion` are required:

```nix
{ config, ... }:
{
  registry.hosts.<hostname> = {
    users = with config.registry.userNames; [ <username> ];
    system = "x86_64-linux";
    stateVersion = "<current-nixos-version>";

    machineModules = [          # what this machine physically is - see Outputs above
      ./_hardware.nix
      ../_uefi-systemd-boot.nix
      # ./_disko.nix            # if this host partitions its own disks
    ];

    # domain = "example.com";   # primary FQDN if it serves anything
    # hostId = "deadbeef";      # required for ZFS
    # extraGroups = [ "plugdev" ];

    aspects = with config.aspectLib.names; [
      bundle.workstation        # or: bundle.server / bundle.base
    ];

    nixosModule = { pkgs, ... }: {     # or finixModule on a finix host
      users.users.<username>.initialPassword = "changeme";
    };
  };
}
```

Aspects here reach the **system** layer only - home slots come from
`modules/users/<user>.nix`; see [Module System](#module-system).

### 2. Check it resolved

```bash
nix eval --json --file . resolved.<hostname> | jq   # layers hit, aggregators, inert names
nix-build . --attr checks.<system>-<hostname> --no-out-link
```

### 3. Install

<system> refers to finixConfigurations or nixosConfigurations

```bash
nixos-install --system "$(nix-build --file . --attr <system>.<hostname>.config.system.build.toplevel --no-out-link)" --option experimental-features "nix-command"
```

or when rebuilding the first time after a graphical install 

```bash
sudo nixos-rebuild switch --file . --attr <system>.<hostname> --option "extra-experimental-features" "nix-command"
```

> After the first build, experimental features are enabled permanently via the `core` module - subsequent rebuilds don't need the flag.

---

## Common Commands

### Rebuild

```bash
nh os switch -f default.nix -a <system>.hostname        # rebuild + switch current host (NixOS + hjem)
```

### Remote deploy (deploy-rs)

`deploy.nodes` is generated from the registry (`modules/builders/deploy.nix`) and
exposed by `default.nix` for every NixOS host, so remote pushes are rollback-safe.
Flakeless, deploy-rs reads the nodes via `--file` (experimental in deploy-rs):

```bash
deploy --file . <host>                 # build locally, copy closure, activate on remote
deploy --file . <host> --skip-checks   # skip the (slow) pre-flight checks
```

Magic rollback is on: if the new config breaks connectivity, the target auto-reverts
to the previous generation on its own. Nodes set `sshOpts = ["-o" "ControlPath=none"]`
so the confirmation step uses a real fresh login rather than a multiplexed master
socket (otherwise a broken sshd/firewall could falsely confirm).

### Maintenance

```bash
nix-shell                 # or `nix develop` - tack, nixfmt-tree, sops, age, ssh-to-age,
                          #   deploy-rs, disko, nvd, nix-output-monitor, jq
tack update               # update all pins (.tack/pins.lock.json)
tack update <input>       # update a specific pin
nix-build . --attr checks.nixos-<host> --no-out-link   # eval/build a host
nh clean all              # remove old generations
```

### Images, VMs and containers

Nothing builds these automatically - they are lazy, and CI only builds `checks`. Ask
for one by name:

```bash
nix eval --file . images.<host> --apply builtins.attrNames   # list the 26 formats
nix build --file . images.<host>.raw-efi                     # a bootable disk image
nix build --file . images.<host>.proxmox-lxc                 # an LXC container tarball
nix-build . --attr packages.vm-<host> --no-out-link          # a finix test VM
nix-build . --attr containers.<name> --no-out-link           # then: podman load < result
```

Images are built **without** `machineModules` - a VM or an image is not this machine,
so its hardware, disks and bootloader are omitted by design. Anything a machine-less
build still needs is therefore not a machine fact and belongs on an aspect or on the
host's `nixosModule` instead.

Not every host × format pair is meaningful. Desktop hosts fail the container and
installer formats: nixpkgs' `profiles/minimal.nix` (pulled in by `lxc`, `kexec`)
disables things a desktop aspect enables, like `services.udisks2`. Left unforced on
purpose - a desktop laptop as an LXC container is not worth building.

### What did my change actually move?

Most edits here are meant to be refactors, and a refactor that moves a closure is a
bug. `scripts/drvdiff.sh [REF]` compares every `checks`, `packages` and `containers`
output against another revision by `.drv` path - a transitive fingerprint, so an
unchanged one proves nothing in that derivation's build-time closure changed. CI runs
it on every push; `--help` covers the verdicts, the exit codes and why both sides are
pinned to one revision. It reports *that* something moved, not what inside it did -
for that, `nvd diff-closures` in the devShell.

### Inspection

```bash
nix eval --file . nixosConfigurations --apply builtins.attrNames   # list hosts
nix repl --file .         # open repl with default.nix loaded
```

### Flake wrapper

`flake.nix` re-exports `default.nix`. It is **not** a second source of truth: it
defines no configuration of its own, and rebuilds stay on `--file .`. What it does do
is make every output above reachable from the flake CLI and consumable as an input.

It passes every output in the table above through unchanged, and adds two things a
flake needs and `--file .` has no use for:

- **`checks` and `packages` keyed by system**, which a flake requires.
- **`formatter.<system>`**, so `nix fmt` works from the flake CLI too.

```bash
nix flake show
nix build .#checks.x86_64-linux.nixos-athena
nix build .#packages.x86_64-linux.vm-icarus
nix develop
nix fmt
```

**Same commit, same closure.** `nix build .#checks.x86_64-linux.nixos-athena` and
`nix-build . --attr checks.nixos-athena` produce the identical derivation. That
holds only because the flake passes `rev` down: `core` bakes the revision into a
`nixos-revision` script, and a flake source tree has no readable `.git`, so without
threading it the two entry points would disagree and rebuild each other's work.

`TACK_OVERRIDES` is the one thing that does not work through the flake - it reads the
environment, which pure evaluation forbids, so it needs `--file .`.

---

## Hosts

Every host, with its class, users, resolved aspect count and domain, is generated into
[`modules/MODULES.md`](modules/MODULES.md) from `config.registry` itself, so it cannot
drift. NixOS hosts are also deploy-rs targets (`deploy --file . <host>`); finix hosts
are built with `nixos-rebuild --file . --attr finixConfigurations.<host>`, not deployed.

---

## Module System

Each aspect is declared as `aspects.<name>.{nixos,home,finix}` (any subset of the
three layer slots) plus an optional `aspects.<name>.includes`. They are selected
through a **single `aspects` list**, which exists on both `registry.hosts.<host>`
and `registry.users.<user>`:

```nix
aspects = with config.aspectLib.names; [ bundle.workstation desktop.compositors.niri dev.tools.git ];
```

**The two selection sites are asymmetric.** A *host* selection reaches the system
layers only; the home layer is resolved from **user aspects alone**
(`modules/builders/homeModules.nix`). So a home-only aspect named on a host is
silently inert - list it on the user instead. The system sees the union of both.

**Role bundles & aggregators.** Names in `aspects` can also be *aggregators* -
aspects that carry only an `includes` list, expanding to other aspects via transitive
closure. The role bundles `bundle.base`, `bundle.workstation` and `bundle.server` are
the top-level ones (e.g. `bundle.workstation` pulls in `bundle.base`,
`bundle.desktop`, …), so most hosts list a bundle plus a few extras. An aggregator
needs no layer slot - it contributes only its members. Aggregators live next to what
they aggregate (`bundle.base` in `features/base/`, `bundle.workstation` in
`features/profiles/`), not in a directory of their own.

`includes` is layer-blind on purpose: a name is resolved once, then each layer takes
only the slots that exist. `services` includes `graphics` (nixos-only) and
`userServices` (home-only) in one flat list, and each reaches only where it applies.

`modules/builders/generation.nix` resolves a host's aspects and routes each to
whichever layer slot it defines (home slots are spliced into that host's hjem user):

| Slot defined on the aspect | Applied to |
|------------------|-----------|
| `.nixos` only | the system |
| `.home` only | hjem (home) |
| `.finix` | a finix system |
| several | each corresponding layer |

This means a compositor (nixos session + hjem config) can't be half-wired. `aspects` is enum-typed against the set of known aspect names, so a typo fails at eval and the error lists every valid name. The `with config.aspectLib.names;` scope lets names be written bare instead of quoted.

**Listed = enabled** - naming a module in `aspects` is sufficient to enable it. No extra `.enable = true` needed except for:
- Compositor selection (`features.compositors.niri.enable`)
- Server domain (`features.server.domain`)
- Per-monitor config (`features.compositors.monitors.<name>`)

See [`modules/MODULES.md`](modules/MODULES.md) for the full module reference.
