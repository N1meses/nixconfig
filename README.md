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
│   ├── features/          # Feature modules - aggregators live beside what they aggregate
│   │   ├── base/          # core (nixos + hjem), local, sops, overlays, base bundle
│   │   ├── desktop/       # compositors, apps, services, noctalia, tools
│   │   ├── dev/           # editors, tools, languages
│   │   ├── profiles/      # gaming, laptop, performance, virtualisation, mkVM, workstation, server
│   │   ├── rescue/        # minimal rescue shell
│   │   ├── server/        # media/, security/, share/, vpn/ + monitoring, nginx, sshd, serverCore
│   │   └── shell/         # zsh, starship, ssh, shell tools, cliEnv + shell bundles
│   ├── hosts/             # Per-host registry entries + `_`-prefixed machine modules
│   ├── users/             # Per-user registry entries (their own aspects list)
│   ├── options/           # schema - registry, aspects, fleet, shared compositor options
│   └── builders/          # generation (system eval), deploy nodes, checks, docs, nixpkgs
└── modules/MODULES.md     # Full module reference - GENERATED, see below
```

`default.nix` collects every `.nix` under `modules/` automatically - no manual imports
needed when adding new modules. Files whose name starts with `_` are skipped: that is
how per-host machine modules (`_hardware.nix`, `_disko.nix`, `_devices.nix`) stay out of
the top-level eval and get referenced explicitly from `machineModules` instead.

`default.nix` takes one optional argument, `rev`, which every `--file .` entry point
auto-calls with its default. Only `flake.nix` passes it: a flake source tree has no
readable `.git`, and `core` bakes the revision into `nixos-revision`, so passing it is
what keeps a flake build and a `--file .` build of the same commit byte-identical.
The one place the auto-call does *not* happen is `nix eval --apply` without an attribute
path - there, import it yourself: `nix eval --impure --expr '(import ./. { })' --apply f`.

---

## First-time Installation


### 1. Clone the repo

```bash
git clone https://github.com/N1meses/nixconfig 
```

### 2. Generate hardware configuration

```bash
nixos-generate-config --root /mnt --show-hardware-config > modules/hosts/<hostname>/_hardware.nix
```

### 3. Create host file

Create `modules/hosts/<hostname>/<hostname>.nix` - use an existing host as reference (e.g. `nimeses.nix`). A host is a single `registry.hosts.<hostname>` entry; host-specific inline config lives on the entry itself as `nixosModule`/`homeModule` (there is no separate `configurations.*` block anymore - that was collapsed into the registry):

```nix
{config, ...}: {
  registry.hosts.<hostname> = {
    users = with config.registry.userNames; [ <username> ];
    system = "x86_64-linux";
    stateVersion = "<current-nixos-version>";
    machineModules = [ ./_hardware.nix ];   # what this machine physically is
    # domain = "example.com";     # primary FQDN (public or tailnet) if it serves anything
    # hostId = "deadbeef";        # required for ZFS
    # extraGroups = ["plugdev"];

    # Aspect names for the *system*: .nixos on a nixos host, .finix on a finix one.
    # Home slots are NOT reached from here - list those on the user instead.
    # Start from a role bundle (bundle.base / bundle.workstation / bundle.server),
    # then add extras. Validated against an enum of known names - a typo fails at
    # eval with the full list.
    aspects = with config.aspectLib.names; [
      bundle.workstation     # or: bundle.server / bundle.base
      # add feature module names here
    ];

    # Host-specific inline config (boot, hardware tweaks, extra packages, sops).
    # networking.hostName is set by the generator from the registry key.
    nixosModule = {pkgs, ...}: {
      users.users.<username>.initialPassword = "changeme";
    };

    homeModule = {pkgs, ...}: {
      # hjem home slot - e.g. packages, rum.programs.*, features.compositors.*, ...
    };
  };
}
```

### 4. Install

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

## Adding a New Host

1. Create `modules/hosts/<hostname>/` directory
2. Add `_hardware.nix` (from `nixos-generate-config`) and, if the host partitions its
   own disks, `_disko.nix` - the `_` prefix keeps them out of the top-level eval
3. Add `<hostname>.nix` with `registry.hosts.<hostname>`: `machineModules` pointing at
   those files, the `aspects` list, and any host-specific `nixosModule`/`finixModule`
   inline config
4. Rebuild: `nh os switch -f default.nix -a <system>.<hostname>`

Machine modules are listed explicitly rather than hidden behind a single import so a
host's physical makeup is readable without opening another file - and so builds that
are *not* this machine (VMs, images) can omit them wholesale.

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
nix-shell                 # or `nix develop` - tack, sops, deploy-rs, disko, nvd, nixfmt
tack update               # update all pins (.tack/pins.lock.json)
tack update <input>       # update a specific pin
nix-build . --attr checks.nixos-<host> --no-out-link   # eval/build a host
nh clean all              # remove old generations
```

### What did my change actually move?

Most edits here are meant to be refactors, and a refactor that moves a closure is a
bug. `scripts/drvdiff.sh` compares every `checks`, `packages` and `containers` output
against another revision, by `.drv` path — a transitive fingerprint, so an unchanged
one means nothing anywhere in that derivation's build-time closure changed:

```bash
./scripts/drvdiff.sh              # working tree vs HEAD
./scripts/drvdiff.sh main         # working tree vs main
./scripts/drvdiff.sh --help       # verdicts, exit codes, why the rev is forced
```

```
drvdiff: HEAD -> working tree
  removed  checks.aarch64-linux
  removed  checks.x86_64-linux
  fixed    packages.vm-bellerophon
  fixed    packages.vm-icarus
  fixed    packages.vm-nimeses
  fixed    packages.vm-phaethon

18 unchanged, 0 moved, 0 added, 2 removed, 4 fixed, 0 broken
```

Both sides are evaluated with the *same* forced revision, because `core` bakes the git
rev into a `nixos-revision` script — without that, every host moves on every commit and
the diff says nothing. Exit codes: `0` nothing moved, `1` something moved, `2` bad ref,
`3` an output stopped evaluating. CI gates on `3` only, since a real change is *supposed*
to move closures.

It reports *that* something moved, not what inside it did. For that, build both and use
`nvd diff-closures` (in the devShell).

### Inspection

```bash
nix eval --file . nixosConfigurations --apply builtins.attrNames   # list hosts
nix eval --json --file . resolved.<host>   # what this host's aspects resolved to
nix repl --file .         # open repl with default.nix loaded
```

### Flake wrapper

`flake.nix` re-exports `default.nix` and adds nothing of its own - the build stays on
`--file .`. It exists so the config is consumable as an input and reachable by the flake
CLI, and it splits `checks` and `packages` by the system each derivation builds for,
which a flake requires and `--file .` has no use for:

```bash
nix flake show
nix build .#packages.x86_64-linux.vm-icarus
nix develop
```

Same commit, same closure: `nix build .#checks.x86_64-linux.nixos-athena` and
`nix-build . --attr checks.nixos-athena` produce the identical derivation.

`TACK_OVERRIDES` is the exception - it reads the environment, which pure evaluation
forbids, so it only works through `--file .`.

---

## Hosts

The host table is **generated** - see [`modules/MODULES.md`](modules/MODULES.md), which
lists every host with its class, users, resolved aspect count and domain. It is built
from `config.registry` itself, so it cannot drift.

NixOS hosts are also deploy-rs targets (`deploy --file . <host>`); finix hosts are
built with `nixos-rebuild --file . --attr finixConfigurations.<host>`, not deployed.

To ask what a single host actually resolved to:

```bash
nix eval --json --file . resolved.nimeses | jq        # layers hit, aggregators, inert names
```

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
