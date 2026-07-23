# Module Library

## File Tree

```
modules/
├── aggregators/                    # role bundles + aspect aggregators (aspects.<name>.includes)
│   ├── base.nix                    # bundle → core, shell, local, users, tailscale, helix
│   ├── workstation.nix             # bundle → base, desktop, niri, ly, git, nix, zed, kitty
│   ├── server.nix                  # bundle → base, serverCore, sshd, git, network, nh, yazi
│   ├── shell.nix                   # → zsh, shellTools, starship, ssh
│   ├── apps.nix                    # → yazi, browser, gtk, nh, fastfetch
│   ├── desktop.nix                 # → services, apps, noctalia
│   └── services.nix                # aspect with real nixos/home/finix slots (not just includes) — see below
├── features/
│   ├── base/
│   │   ├── core.nix                # nixos: boot, Nix settings/GC, substituters, nix-ld (home slot empty)
│   │   ├── users.nix               # user accounts (nixos + finix), authorized keys
│   │   ├── overlays.nix            # package overlays
│   │   ├── local.nix               # timezone (Europe/Berlin), locale (en_US/de_DE), keymap (de)
│   │   ├── cachyosKernel.nix       # CachyOS kernel overlay import
│   │   └── sops.nix                # sops-nix helper (defaultSopsFile per host)
│   ├── desktop/
│   │   ├── apps/
│   │   │   ├── term/               # foot, ghostty, kitty
│   │   │   ├── browser.nix         # brave + MIME associations
│   │   │   ├── fastfetch.nix       # fastfetch with Nix logo
│   │   │   ├── fuzzel.nix          # fuzzel launcher
│   │   │   ├── gtk.nix             # GTK theme (adw-gtk3, Pop icons)
│   │   │   ├── nh.nix              # nh helper + auto-cleanup
│   │   │   └── yazi.nix            # yazi + termfilechooser portal
│   │   ├── compositors/            # hyprland, mango, niri (each nixos + hjem) + options.nix (shared features.compositors.*)
│   │   ├── noctalia/               # noctalia.nix (shell + lib fns) + noctaliaSettings.nix
│   │   ├── services/               # audio, bluetooth, fonts, graphics, greetd, ly, mako, music, portals, session, userServices
│   │   └── tools/                  # screenshot, wallpaper (hjem)
│   ├── dev/
│   │   ├── editors/                # helix, zed (hjem)
│   │   ├── languages/              # bash c css go html java javascript json lua markdown nix puml python rust yaml zig (hjem, import = enable)
│   │   └── tools/                  # build cli database direnv git network security (import = enable)
│   ├── profiles/                   # gaming, laptop, performance, virtualisation, mkVM (nixos, import = enable)
│   ├── rescue/rescue.nix           # rescue/install toolkit (disko, cryptsetup, parted, …)
│   ├── server/                     # nixos, import = enable
│   │   ├── serverCore.nix          # firewall, fail2ban base, lid-switch ignore, plugdev/media groups, htop/tmux/rsync
│   │   ├── ssh.nix                 # OpenSSH (no root, key-only) + fail2ban sshd jail (module key: sshd)
│   │   ├── nginx.nix               # nginx + gzip + fail2ban http jails
│   │   ├── monitoring.nix          # netdata (withCloudUi dashboard) on tailscale0:19999
│   │   ├── media/                  # jellyfin, navidrome, nextcloud, ownCloud, nixarr
│   │   ├── security/               # authentik, restic, vaultwarden
│   │   ├── share/                  # croc, element, forgejo, matrix, ollama
│   │   └── vpn/                    # airvpn, cloudflared, mullvad, tailscale
│   └── shell/                      # zsh, shellTools, starship, ssh
├── hosts/                          # per-host registry entries (+ hardware/disko/impermanence)
│   ├── nimeses/    hardware, disko          # workstation
│   ├── prometheus/ hardware                 # workstation (NVIDIA)
│   ├── hephaistos/ hardware                 # server (tailnet-only)
│   ├── athena/     hardware                 # server (public, full stack)
│   ├── hermes/     hardware, disko, imperm. # base
│   └── icarus/     hardware, disko          # finix (experimental)
├── options/                        # module schema
│   ├── registry.nix                # registry.hosts + aspects enum (aspectLib.names)
│   ├── aspects.nix                 # aspects.<name>.{nixos,home,finix,includes} + aspectLib helpers
│   ├── fleet.nix                   # cross-host fleet bus (fleet.<host>.{nixos,finix,home})
│   └── outputs.nix                 # top-level output attrs
├── builders/                       # eval → outputs (consumed by default.nix)
│   ├── generation.nix              # registry.hosts → nixos/finix/homeConfigurations (splices each host's hjem user)
│   ├── homeModules.nix             # per-host hjem module assembly (aspect home slots + git identity)
│   ├── deploy.nix                  # deploy-rs deploy.nodes (generated from the registry)
│   ├── finixVm.nix                 # finix VM build (icarus)
│   ├── checks.nix                  # every host toplevel folded into the `checks` attr
│   ├── hjemChecks.nix              # validates generated hjem dotfiles (syntax/parse gate)
│   └── nixpkgs.nix                 # nixpkgs config + overlays
└── MODULES.md                      # this file
```

---

## Aggregators & Role Bundles

Aggregators live in `modules/aggregators/` and are aspects that carry only an
`aspects.<name>.includes` list — a name in a host's `aspects` list that expands to
other aspect names via transitive closure (`aspectLib.resolveAspects`). An aggregator
needs **no layer slot**; it contributes only its members. The **role bundles**
(`base`, `workstation`, `server`) are the top-level aggregators — a host lists a bundle
plus a few extras instead of repeating the common set.

| Aggregator | Kind | Expands to |
|------------|------|-----------|
| `base` | role bundle | core, shell, local, users, tailscale, helix |
| `workstation` | role bundle | **base**, desktop, niri, ly, git, nix, zed, kitty |
| `server` | role bundle | **base**, serverCore, sshd, git, network, nh, yazi |
| `shell` | aggregator | zsh, shellTools, starship, ssh |
| `apps` | aggregator (hjem) | yazi, browser, gtk, nh, fastfetch |
| `desktop` | aggregator | services, apps, noctalia |
| `services` | **aspect w/ layer slots** | see below |

`services` is deliberately **not** a pure-`includes` aggregator — it carries real
nixos/home/finix slots because it encodes cross-layer asymmetry that name-based
routing can't express: nixos imports `graphics, fonts, portals, audio, bluetooth`; hjem imports
`userServices`; finix imports `fonts, ly`. Don't "simplify" it into an aggregator.

---

## Desktop

Compositors (niri, hyprland, mango) are **not** bundled by `desktop` — each is added
directly by the host (`workstation` adds `niri`).

### Apps

| Module | Side | Packages | Options |
|--------|------|----------|---------|
| `browser` | hjem | brave | `features.apps.browser.defaultBrowser` (brave\|firefox\|chromium) |
| `fastfetch` | hjem | — | — |
| `foot` | hjem | foot (`apps/term/`) | — |
| `ghostty` | hjem | ghostty (`apps/term/`) | — |
| `kitty` | hjem | kitty (`apps/term/`) | — |
| `fuzzel` | hjem | fuzzel | — |
| `gtk` | hjem | adw-gtk3, pop-icon-theme | — |
| `nh` | hjem | — | — |
| `yazi` | hjem | xdg-desktop-portal-termfilechooser, xdg-terminal-exec | `features.apps.yazi.terminalFilechooser.terminal` (default: ghostty) |

### Compositors

| Module | Side | Options |
|--------|------|---------|
| `niri` | nixos + hjem | `features.compositors.niri.enable`, `.extraBinds`, `.autoStart`, `.input.touchpad.enable` |
| `hyprland` | nixos + hjem | `features.compositors.hyprland.enable`, `.extraBinds`, `.autoStart`, `.input.touchpad.enable` |
| `mango` | nixos + hjem | import = enable (no `.enable`), `features.compositors.mango.extraBinds`, `.autoStart` |
| `lib/compositors` | nixos + hjem | `features.compositors.monitors.<name>.{resolution, refreshRate, scale, transform, position, vrr.enable, primary}` |

### Bar

| Module | Side | Configures |
|--------|------|------------|

### Services

| Module | Side | Configures | Options |
|--------|------|------------|---------|
| `audio` | nixos | PipeWire + WirePlumber + RTKit | — |
| `bluetooth` | nixos | Bluetooth + Blueman | — |
| `fonts` | nixos (+ finix) | ibm-plex, google-fonts, material-symbols, nerd-fonts | — |
| `graphics` | nixos | DRM, modesetting, XKB (de) | — |
| `greetd` | nixos | tuigreet, GNOME Keyring PAM | — |
| `ly` | nixos (+ finix) | ly display manager, GNOME Keyring PAM | — |
| `mako` | hjem | Mako notification daemon | — |
| `music` | nixos | MPD | — |
| `portals` | nixos | XDG portal, dbus, udisks2 | — |
| `session` | finix | seatd, getty tty1, doas, greetd PAM (finix session) | — |
| `userServices` | hjem | gnome-keyring, udiskie | `features.services.user.storage.udiskie.{notify, automount}` |

### Tools

| Module | Side | Configures | Options |
|--------|------|------------|---------|
| `screenshot` | hjem | screenshot tooling | — |
| `wallpaper` | hjem | wallpaper configuration | `features.compositors.wallpaper.image` |

### Noctalia

| Module | Side | Configures |
|--------|------|------------|
| `noctalia` | nixos + hjem | noctalia-shell shell layer, spawn-at-startup, layer rules |
| `noctaliaSettings` | hjem | Full noctalia config (bar, launcher, audio, notifications, wallpaper, etc.) |

`noctalia.nix` also exposes two shared lib functions:

| Function | Usage | Output |
|----------|-------|--------|
| `config.aspectLib.mkNoctaliaNiri` | `mkNoctaliaNiri "volume increase"` | `["noctalia-shell" "ipc" "call" "volume" "increase"]` |
| `config.aspectLib.mkNoctaliaHypr` | `mkNoctaliaHypr "volume increase"` | `"exec, noctalia-shell ipc call volume increase"` |

---

## Dev

### Editors

| Module | Side | Packages | Sets |
|--------|------|----------|------|
| `helix` | hjem | — | `EDITOR=hx`, `VISUAL=hx` (mkDefault), mimeApps text/* → helix, `clipboard-provider` (mkDefault wayland) |
| `zed` | hjem | zed-editor-fhs | `VISUAL=zeditor --wait` (overrides helix default) |

> Servers set `programs.helix.settings.editor.clipboard-provider = "termcode"` in their
> host `homeModule` so yank/paste works over SSH (OSC 52) where there's no Wayland clipboard.

### Tools

All hjem side. Import = enable.

| Module | Packages |
|--------|----------|
| `build` | gnumake, cmake, pkg-config |
| `cli` | jq, yq, sd, just, hyperfine, tokei, watchexec, btop, gh |
| `database` | sqlite, postgresql |
| `direnv` | direnv + nix-direnv |
| `git` | git, delta, lazygit, pre-commit, commitizen, lefthook, tig, git-absorb |
| `network` | httpie, bandwhich |
| `security` | nmap, netcat, mtr, tcpdump, traceroute |

### Languages

All hjem side. Import = enable.

| Module | Packages | Helix LSP |
|--------|----------|-----------|
| `bash` | bash-language-server, shellcheck, shfmt, bash | bash-language-server |
| `c` | clang-tools, ccls, gcc | clangd (C + C++) |
| `css` | vscode-langservers-extracted | vscode-css-languageserver |
| `go` | gopls, gotools, golangci-lint, go | gopls |
| `html` | vscode-langservers-extracted | vscode-html-languageserver |
| `java` | jdk, jdt-language-server, gradle | jdtls |
| `javascript` | typescript-language-server, prettier, eslint, bun | typescript-language-server (JS + TS) |
| `json` | vscode-langservers-extracted | vscode-json-languageserver |
| `lua` | lua-language-server, stylua, lua | lua-language-server |
| `markdown` | marksman, markdownlint-cli | marksman |
| `nix` | nixd, alejandra | nixd + alejandra formatter |
| `puml` | plantuml | — |
| `python` | pyright, ruff, python3, uv | pyright |
| `rust` | rust-analyzer, rustfmt, clippy, rustc, cargo | rust-analyzer |
| `yaml` | yaml-language-server, yamlfmt | yaml-language-server |
| `zig` | zls, zig | zls |

---

## Server

All nixos side. Import = enable. `features.server.domain` must be set when importing
nginx or any service with a reverse proxy.

### Core

| Module | Configures | Options |
|--------|------------|---------|
| `serverCore` | Firewall, fail2ban base, lid-switch ignore, plugdev/media groups, no docs, htop/tmux/rsync | — |
| `sshd` | OpenSSH (no root, key-only), fail2ban sshd jail | `features.server.sshPort` (default 22) |
| `nginx` | Nginx + gzip + fail2ban http jails | `features.server.domain` |
| `monitoring` | netdata with bundled dashboard (`withCloudUi`), tailscale0:19999 | — |

### VPN (`vpn/`)

| Module | Configures |
|--------|------------|
| `tailscale` | Tailscale, trusts tailscale0 interface |
| `cloudflared` | Cloudflare tunnel |
| `airvpn` | AirVPN system-wide (PostUp rules for Tailscale coexistence) |
| `mullvad` | Mullvad VPN |

### Media (`media/`)

| Module | Configures |
|--------|------------|
| `jellyfin` | Jellyfin, nginx proxy (media.${domain}) |
| `navidrome` | Navidrome music server, nginx proxy, restic backup of `/var/lib/navidrome` |
| `nextcloud` | Nextcloud, nginx proxy |
| `ownCloud` | ownCloud Infinite Scale, nginx proxy |
| `nixarr` | nixarr arr stack |

### Security (`security/`)

| Module | Configures |
|--------|------------|
| `authentik` | Authentik SSO |
| `restic` | `services.restic.backups.system` — daily, keep 7d/4w/6m, sops `restic-password`, repo `/backup/<host>` (default) |
| `vaultwarden` | Vaultwarden (port 8222), nginx proxy, sops env |

Service modules opt into backup by adding their state dir to
`services.restic.backups.system.paths` and pulling in the `restic` aspect.

### Share (`share/`)

| Module | Configures | Options |
|--------|------------|---------|
| `forgejo` | Forgejo (sqlite, LFS, SSH :2222), nginx proxy | — |
| `matrix` | Matrix (Synapse), nginx proxy | — |
| `element` | Element web client, nginx proxy | — |
| `croc` | Croc relay, firewall ports 9009-9013 on tailscale0 | — |
| `ollama` | Ollama with configurable acceleration | `features.server.ollama.{host, port, acceleration}` (rocm\|cuda\|null) |

---

## Base / Core

| Module | Side | Configures |
|--------|------|------------|
| `core` | nixos | systemd-boot, Plymouth, Nix GC/auto-optimise, NetworkManager, nix-ld, **all substituters/caches** (cache.nixos.org, nix-community, niri-nix, noctalia, hyprland, lantian, kopuz). finix slot: limine, nix-daemon, chrony, cron, networkmanager, polkit. (home slot empty — XDG dirs come from hjem) |
| `local` | nixos | Timezone (Europe/Berlin), locale (en_US / de_DE), keymap (de) |
| `cachyosKernel` | nixos | CachyOS kernel overlay import |
| `sops` | nixos | sops-nix helper — per-host `defaultSopsFile`, age key wiring |

`base` is the role bundle (see Aggregators); it pulls in `core`, `shell`, `local`,
`users`, `tailscale`, `helix`.

## Profiles

All nixos side. Import = enable.

| Module | Configures |
|--------|------------|
| `gaming` | Steam, Proton, GameMode, Gamescope, Vulkan, DXVK |
| `laptop` | upower, thermald, power-profiles, libinput touchpad |
| `performance` | TCP tuning, zram (zstd 50%), Nix daemon scheduling |
| `virtualisation` | libvirtd, KVM, virt-manager, KSM, hugepages |
| `mkVM` | build-a-VM helper for a host config |

## Rescue

| Module | Side | Configures |
|--------|------|------------|
| `rescue` | nixos | Install/repair toolkit: nixos-install-tools, disko, cryptsetup, parted, gptfdisk, ntfs3g, exfatprogs, smartmontools, nvme-cli, … |

---

## Shell

| Module | Side | Configures |
|--------|------|------------|
| `shell` | aggregator | zsh, shellTools, starship, ssh |
| `zsh` | nixos + hjem | zsh, eza aliases, history, syntax highlighting, fastfetch on login |
| `shellTools` | hjem | zoxide, fzf, ripgrep, fd |
| `starship` | hjem | Starship prompt (git, nix-shell, python, OS symbol) |
| `ssh` | hjem | SSH config + YubiKey FIDO2 identities, ControlMaster multiplexing, host aliases |

---

## Lib

Infrastructure modules — not imported by hosts, wired in automatically.

| File | Purpose |
|------|---------|
| `compositors.nix` | hjem module — defines all shared `features.compositors.*` options (monitors, gaps, colors, borders, opacity, cursor, keyboard, terminal) |
| `registry.nix` | Defines `options.registry.hosts` — host registry (username, system, stateVersion, domain, hostId, extraGroups, homeDirectory, **aspects**, **nixosModule**, **homeModule**, **finixModule**). Aspect schema + `aspectLib.{names,resolveAspects,…}` live in `options/aspects.nix`, which folds every `aspects.<name>` (incl. `includes` aggregators) into the valid-names enum. |

### Aspects (host module selection)

Each host lists its aspects once as `registry.hosts.<host>.aspects`. Names route to
whichever layer slot they define (`aspects.<name>.nixos` → system,
`.home` → that host's hjem user, `.finix` → a finix system; any subset). Names can
also be **aggregators** (aspects with only an `includes` list) that expand to more
names — see Aggregators & Role Bundles. The option is enum-typed against all aspect
names, so typos fail at eval with the full valid list. Written bare via
`with config.aspectLib.names; [ … ]`.

```nix
registry.hosts.nimeses.aspects = with config.aspectLib.names; [
  workstation                 # role bundle → base + desktop + niri + …
  hardwareNimeses             # host-only
  gaming performance          # extra profiles
];
```

---

## Standalone hjem (`hjem standalone`)

`generation.nix` also emits `homeConfigurations.<host>.<user>` — `{ manifest; packages; }`
in the shape `hjem standalone` consumes (manifest `version = 3`, validated against
hjem's own `manifest/v3.cue`). Keyed by **host** because usernames are not unique
(`bellerophon` uses the `icarus` user).

`hjem.nix` in the repo root is the `--config` entry point: it resolves the current
host from `/etc/hostname` and picks that host's sole user, erroring clearly if a
host ever has more than one.

```bash
hjem standalone build  --config ./hjem.nix   # evaluate + validate, records under builds/
hjem standalone switch --config ./hjem.nix   # APPLY — see warning below
hjem standalone generations / rollback
```

> [!WARNING]
> Do **not** `switch` while the system generation still manages the same files.
> `commonModule` in `generation.nix` splices `hjem.users` into the system with
> `clobberByDefault = true`, and standalone keeps separate state
> (`~/.local/state/hjem/standalone` vs `/var/lib/hjem/manifest-<user>.json`).
> Both would consider themselves the owner and clobber each other's symlinks,
> with the winner decided by whichever ran last. There is no conflict guard in
> the CLI. `build` is always safe — it never links anything.

---

## Deployment (deploy-rs)

`modules/builders/deploy.nix` generates `deploy.nodes` from the registry — one node
per NixOS host (filtered to those with a `nixosConfigurations` entry, so finix
`icarus` is excluded). The nodes are exposed by `default.nix`;
flakeless, deploy-rs reads them via `--file` (experimental in deploy-rs).

```bash
deploy --file . <host>                 # build locally, copy closure, activate remotely
deploy --file . <host> --skip-checks   # skip the slow pre-flight checks
```

Per node: `sshUser = <host>`, `user = "root"`, `interactiveSudo = true`, and
`sshOpts = ["-o" "ControlPath=none"]`. Magic rollback and auto rollback are on
(deploy-rs defaults). **The `sshOpts` line is load-bearing:** without it the
confirmation reconnect can ride an SSH `ControlMaster` socket and *falsely confirm* a
deploy that has actually broken inbound SSH — forcing `ControlPath=none` makes the
confirm a genuine fresh login, so a broken sshd/firewall/network triggers the revert
instead of locking you out.

---

## Secrets (sops-nix)

Secrets are managed with sops-nix + age keys. The `sops` aspect (in `base`) wires the
per-host `defaultSopsFile` and age key; secret-consuming service modules declare
`sops.secrets.<name>` and read `config.sops.secrets.<name>.path`.

| Host | Secret file | Age key location |
|------|-------------|-----------------|
| `nimeses` | `secrets/nimeses.yaml` | `/home/nimeses/.config/sops/age/keys.txt` |
| `hephaistos` | `secrets/hephaistos.yaml` | `/root/.config/sops/age/keys.txt` |
| `athena` | `secrets/athena.yaml` | `/root/.config/sops/age/keys.txt` |

Age keys are derived from SSH host keys (YubiKey-backed on nimeses). Secrets are
root-readable only (never placed in `environment.*`, which is world-readable in the Nix
store). To add a new secret: encrypt with `sops` and reference via
`config.sops.secrets.<name>.path`.
