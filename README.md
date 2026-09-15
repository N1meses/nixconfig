# nixconfig

The config I am currently running.

- **finix** and **nixos** as base systems
- **hjem** + hjem-rum for declarative home management
- **pnix** for input pinning — flakeless, `nixos-rebuild --file .`
- **deploy-rs** for remote deployment
- portable **wrappers**: `nix run github:N1meses/nixconfig#nimeses-helix`

Full reference: [`aspects/MODULES.md`](aspects/MODULES.md) (every aspect) and
[`aspects/FLEET.md`](aspects/FLEET.md) (every host and user). Both generated from aspects themself.

## How it fits together

Everything selectable is a node. Which kind it is comes from which tree it lives in,
not from a field it declares. A node picks others with `includes`, and that only ever
points downward:

```
feature  may include  features
user     may include  users, features
host     may include  hosts, users, features
```

So a host subscribes an account by including it:

```nix
hosts.atlas = {
  description = "public-facing server";
  classes = [ "nixos" ];              # a list — one host can build as both
  stateVersion = "25.05";
  includes = with config.aspectLib.aspectNames; [
    bundle.base
    server.forgejo
    users.atlas                       # ← creates the account
  ];
  nixos = { ... };                    # this machine's own config
};
```

An aspect declares any subset of `nixos`, `finix`, `home`. Name it once; each layer
takes only the slots that exist. **Listed = enabled.**

## Structure

```
default.nix     one evalModules over aspects/
flake.nix       thin re-export; not a second source of truth
aspects/        features/ · hosts/ · users/   ( `_`-prefixed files are skipped )
lib/            options/ = the schema, everything else = the builders
pins.nix        pins with no single consumer; the rest declare their own
```

## Commands

```bash
nh os switch -f default.nix -a nixosConfigurations.<host>   # rebuild this machine
deploy --file . <host>                                      # remote, rollback-safe
nix-shell                                                   # pnix, sops, deploy-rs, disko, nvd…

nix build --file . checks.aspects            # selections that contribute nothing
nix build --file . checks.hjem-<host>        # every dotfile through its own parser
nix build --file . checks.nixos-<host>       # the closure

nix eval --file . packages --apply builtins.attrNames
nix build --file . packages.<host>-vm            # finix test VM
nix build --file . packages.<host>-proxmox       # disk image, if the host asks for one
nix build --file . packages.<user>-<program>     # portable wrapper

pnix update [pin]                            # update pins
scripts/drvdiff.sh [ref]                     # what moved since <ref>, by drvPath
```

Images and VMs build **without** `machineModules` — a VM is not this machine, so its
hardware, disks and bootloader are omitted by design.

```nix
hosts.atlas.images = [ "proxmox" ];   # → packages.atlas-proxmox
```

## Notes

**Inputs** are declared in the node that uses them, not in one manifest. `pnix update` greps the tree and writes `.pnix/pins.lock.json`. A `pins` block must be a literal — the collector calls
each file with arguments that throw.
`PNIX_OVERRIDE=finix=/path/to/finix nh os switch` allows overriding an input imperativly.

**The flake** adds only what `--file .` has no use for: `checks`/`packages` keyed by
system, `formatter`, and `nixosModules`/`finixModules`/`homeModules` so another config
can import a single aspect.

**Wrappers** are derived. Every rum program a user enables that renders
config files becomes `packages.<user>-<program>`, wrapped to read that user's generated
config from the store. Only programs that ignore `XDG_CONFIG_HOME` need an entry in
`lib/wrapper.nix`; there is currently one.
