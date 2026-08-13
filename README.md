# nixconfig

Personal NixOS (+ finix) configuration — flakeless: `evalModules` over `modules/`,
inputs pinned by [tack](.tack/), built with `nixos-rebuild --file . --attr`. Home
is managed by [hjem](https://github.com/feel-co/hjem) + hjem-rum (not home-manager).

## Structure

```
nixconfig/
├── default.nix            # Entry point — evalModules over modules/ (tack-pinned inputs)
├── flake.nix              # util-only: exposes the formatter (nixfmt); NOT the build
├── .tack/                 # input pins (pins.toml + pins.lock.json) + resolver
├── modules/
│   ├── features/          # Feature modules — aggregators live beside what they aggregate
│   │   ├── base/          # core (nixos + hjem), local, sops, overlays, base bundle
│   │   ├── desktop/       # compositors, apps, services, noctalia, tools
│   │   ├── dev/           # editors, tools, languages
│   │   ├── profiles/      # gaming, laptop, performance, virtualisation, mkVM, workstation, server
│   │   ├── rescue/        # minimal rescue shell
│   │   ├── server/        # media/, security/, share/, vpn/ + monitoring, nginx, sshd, serverCore
│   │   └── shell/         # zsh, starship, ssh, shell tools, cliEnv + shell bundles
│   ├── hosts/             # Per-host registry entries + `_`-prefixed machine modules
│   ├── options/           # schema — registry, aspects, fleet, shared compositor options
│   └── builders/          # generation (system eval), deploy nodes, checks, docs, nixpkgs
└── modules/MODULES.md     # Full module reference — GENERATED, see below
```

`default.nix` collects every `.nix` under `modules/` automatically — no manual imports
needed when adding new modules. Files whose name starts with `_` are skipped: that is
how per-host machine modules (`_hardware.nix`, `_disko.nix`, `_devices.nix`) stay out of
the top-level eval and get referenced explicitly from `machineModules` instead.

---

## First-time Installation


### 1. Clone the repo

```bash
git clone https://github.com/N1meses/nixconfig 
```

### 2. Generate hardware configuration

```bash
nixos-generate-config --root /mnt --show-hardware-config > modules/hosts/<hostname>/hardware<Hostname>.nix
```

### 3. Create host file

Create `modules/hosts/<hostname>/<hostname>.nix` — use an existing host as reference (e.g. `nimeses.nix`). A host is a single `registry.hosts.<hostname>` entry; host-specific inline config lives on the entry itself as `nixosModule`/`homeModule` (there is no separate `configurations.*` block anymore — that was collapsed into the registry):

```nix
{config, ...}: {
  registry.hosts.<hostname> = {
    username = "<username>";
    system = "x86_64-linux";
    stateVersion = "<current-nixos-version>";
    # domain = "example.com";     # primary FQDN (public or tailnet) if it serves anything
    # hostId = "deadbeef";        # required for ZFS
    # extraGroups = ["plugdev"];

    # One list of aspect names, each routed to whichever layer it defines:
    # aspects.<name>.nixos -> system, .home -> hjem, .finix -> finix (any subset).
    # Start from a role bundle (base / workstation / server), then add extras.
    # Validated against an enum of known names — a typo fails at eval with the full list.
    aspects = with config.aspectLib.names; [
      workstation            # or: server / base
      hardware<Hostname>
      # add feature module names here
    ];

    # Host-specific inline config (boot, hardware tweaks, extra packages, sops).
    # networking.hostName is set by the generator from the registry key.
    nixosModule = {pkgs, ...}: {
      users.users.<username>.initialPassword = "changeme";
    };

    homeModule = {pkgs, ...}: {
      # hjem home slot — e.g. packages, rum.programs.*, features.compositors.*, ...
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

> After the first build, experimental features are enabled permanently via the `core` module — subsequent rebuilds don't need the flag.

---

## Adding a New Host

1. Create `modules/hosts/<hostname>/` directory
2. Add `_hardware.nix` (from `nixos-generate-config`) and, if the host partitions its
   own disks, `_disko.nix` — the `_` prefix keeps them out of the top-level eval
3. Add `<hostname>.nix` with `registry.hosts.<hostname>`: `machineModules` pointing at
   those files, the `aspects` list, and any host-specific `nixosModule`/`finixModule`
   inline config
4. Rebuild: `nh os switch -f default.nix -a <system>.<hostname>`

Machine modules are listed explicitly rather than hidden behind a single import so a
host's physical makeup is readable without opening another file — and so builds that
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
tack update               # update all pins (.tack/pins.lock.json)
tack update <input>       # update a specific pin
nix-build --file . --attr checks.host-<host> --no-out-link   # eval/build a host
nh clean all              # remove old generations
```

### Inspection

```bash
nix eval --file . nixosConfigurations --apply builtins.attrNames   # list hosts
nix repl --file .         # open repl with default.nix loaded
```

---

## Hosts

The host table is **generated** — see [`modules/MODULES.md`](modules/MODULES.md), which
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
three layer slots) plus an optional `aspects.<name>.includes`. A host selects them
through a **single `aspects` list** in its `registry.hosts.<host>` entry:

```nix
aspects = with config.aspectLib.names; [ workstation niri git ];
```

**Role bundles & aggregators.** Names in `aspects` can also be *aggregators* —
aspects that carry only an `includes` list, expanding to other aspects via transitive
closure. The role bundles `base`, `workstation`, and `server` are the top-level ones
(e.g. `workstation` pulls in `base`, `desktop`, `niri`, …), so most hosts list a bundle
plus a few extras. An aggregator needs no layer slot — it contributes only its members.
Aggregators live next to what they aggregate (`base` in `features/base/`, `workstation`
in `features/profiles/`), not in a directory of their own.

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

**Listed = enabled** — naming a module in `aspects` is sufficient to enable it. No extra `.enable = true` needed except for:
- Compositor selection (`features.compositors.niri.enable`)
- Server domain (`features.server.domain`)
- Per-monitor config (`features.compositors.monitors.<name>`)

See [`modules/MODULES.md`](modules/MODULES.md) for the full module reference.
