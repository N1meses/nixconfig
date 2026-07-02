# Module Library

## File Tree

```
modules/
├── aggregators/                    # role bundles + aspect aggregators (flake.aspectInclude keys)
│   ├── base.nix                    # bundle → core, shell, local, users, tailscale, helix
│   ├── workstation.nix             # bundle → base, desktop, niri, ly, git, nix, zed, kitty
│   ├── server.nix                  # bundle → base, serverCore, sshd, git, network, nh, yazi
│   ├── shell.nix                   # → zsh, shellTools, starship, ssh
│   ├── apps.nix                    # → yazi, browser, gtk, nh, fastfetch
│   ├── desktop.nix                 # → services, apps, noctalia
│   └── services.nix                # direct-import module (nixos+HM+finix), deliberately NOT aspectInclude
├── features/
│   ├── base/
│   │   ├── core.nix                # nixos: boot, Nix settings/GC, substituters, nix-ld · HM: home-manager, XDG
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
│   │   ├── bar/waybar.nix          # Waybar status bar
│   │   ├── compositors/            # hyprland, mango, niri (each nixos + HM)
│   │   ├── noctalia/               # noctalia.nix (shell + lib fns) + noctaliaSettings.nix
│   │   ├── services/               # audio, bluetooth, fonts, graphics, greetd, ly, mako, music, portals, session, userServices
│   │   └── tools/                  # screenshot, wallpaper (HM)
│   ├── dev/
│   │   ├── editors/                # helix, zed (HM)
│   │   ├── languages/              # bash c css go html java javascript json lua markdown nix puml python rust yaml zig (HM, import = enable)
│   │   └── tools/                  # build cli database direnv git network opencode security (HM, import = enable)
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
├── lib/
│   ├── compositors.nix             # shared features.compositors.* options (monitors, gaps, colors, …)
│   └── registry.nix                # registry.hosts + aspects (enum + flake.lib.aspects) + aspectInclude closure
├── meta/
│   ├── flakeParts.nix              # flake-parts setup
│   ├── generation.nix              # NixOS generator: registry.hosts → nixosConfigurations (commonModule: hostName, domain)
│   ├── homeModules.nix             # home-manager routing / homeConfigurations
│   ├── deploy.nix                  # deploy-rs deploy.nodes (generated from the registry)
│   ├── minimalHosts.nix            # <host>Minimal install/rescue nixosConfigurations
│   ├── finixVm.nix                 # finix VM build (icarus)
│   ├── checks.nix                  # every host toplevel into nix flake check
│   ├── nixpkgs.nix                 # nixpkgs config + overlays
│   ├── overlays.nix                # package overlays
│   └── users.nix                   # user account definitions
└── MODULES.md                      # this file
```

---

## Aggregators & Role Bundles

Aggregators live in `modules/aggregators/` and are keyed entries of
`flake.aspectInclude.<name>` — a name in a host's `aspects` list that expands to a
list of other aspect names via transitive closure (`resolveAspects`). An aggregator
key needs **no backing module**; it contributes only its members. The **role bundles**
(`base`, `workstation`, `server`) are the top-level aggregators — a host lists a bundle
plus a few extras instead of repeating the common set.

| Aggregator | Kind | Expands to |
|------------|------|-----------|
| `base` | role bundle | core, shell, local, users, tailscale, helix |
| `workstation` | role bundle | **base**, desktop, niri, ly, git, nix, zed, kitty |
| `server` | role bundle | **base**, serverCore, sshd, git, network, nh, yazi |
| `shell` | aggregator | zsh, shellTools, starship, ssh |
| `apps` | aggregator (HM) | yazi, browser, gtk, nh, fastfetch |
| `desktop` | aggregator | services, apps, noctalia |
| `services` | **direct-import module** | see below |

`services` is deliberately **not** an aspectInclude — it stays a per-layer
direct-import module because it encodes cross-layer asymmetry that name-based routing
can't express: nixos imports `graphics, fonts, portals, audio, bluetooth`; HM imports
`userServices`; finix imports `fonts, ly`. Don't "simplify" it into an aggregator.

---

## Desktop

Compositors (niri, hyprland, mango) are **not** bundled by `desktop` — each is added
directly by the host (`workstation` adds `niri`).

### Apps

| Module | Side | Packages | Options |
|--------|------|----------|---------|
| `browser` | HM | brave | `features.apps.browser.defaultBrowser` (brave\|firefox\|chromium) |
| `fastfetch` | HM | — | — |
| `foot` | HM | foot (`apps/term/`) | — |
| `ghostty` | HM | ghostty (`apps/term/`) | — |
| `kitty` | HM | kitty (`apps/term/`) | — |
| `fuzzel` | HM | fuzzel | — |
| `gtk` | HM | adw-gtk3, pop-icon-theme | — |
| `nh` | HM | — | — |
| `yazi` | HM | xdg-desktop-portal-termfilechooser, xdg-terminal-exec | `features.apps.yazi.terminalFilechooser.terminal` (default: ghostty) |

### Compositors

| Module | Side | Options |
|--------|------|---------|
| `niri` | nixos + HM | `features.compositors.niri.enable`, `.extraBinds`, `.autoStart`, `.input.touchpad.enable` |
| `hyprland` | nixos + HM | `features.compositors.hyprland.enable`, `.extraBinds`, `.autoStart`, `.input.touchpad.enable` |
| `mango` | nixos + HM | import = enable (no `.enable`), `features.compositors.mango.extraBinds`, `.autoStart` |
| `lib/compositors` | nixos + HM | `features.compositors.monitors.<name>.{resolution, refreshRate, scale, transform, position, vrr.enable, primary}` |

### Bar

| Module | Side | Configures |
|--------|------|------------|
| `waybar` | HM | Waybar status bar |

### Services

| Module | Side | Configures | Options |
|--------|------|------------|---------|
| `audio` | nixos | PipeWire + WirePlumber + RTKit | — |
| `bluetooth` | nixos | Bluetooth + Blueman | — |
| `fonts` | nixos (+ finix) | ibm-plex, google-fonts, material-symbols, nerd-fonts | — |
| `graphics` | nixos | DRM, modesetting, XKB (de) | — |
| `greetd` | nixos | tuigreet, GNOME Keyring PAM | — |
| `ly` | nixos (+ finix) | ly display manager, GNOME Keyring PAM | — |
| `mako` | HM | Mako notification daemon | — |
| `music` | nixos | MPD | — |
| `portals` | nixos | XDG portal, dbus, udisks2 | — |
| `session` | finix | seatd, getty tty1, doas, greetd PAM (finix session) | — |
| `userServices` | HM | gnome-keyring, udiskie | `features.services.user.storage.udiskie.{notify, automount}` |

### Tools

| Module | Side | Configures | Options |
|--------|------|------------|---------|
| `screenshot` | HM | screenshot tooling | — |
| `wallpaper` | HM | wallpaper configuration | `features.compositors.wallpaper.image` |

### Noctalia

| Module | Side | Configures |
|--------|------|------------|
| `noctalia` | nixos + HM | noctalia-shell shell layer, spawn-at-startup, layer rules |
| `noctaliaSettings` | HM | Full noctalia config (bar, launcher, audio, notifications, wallpaper, etc.) |

`noctalia.nix` also exposes two shared lib functions:

| Function | Usage | Output |
|----------|-------|--------|
| `config.flake.lib.mkNoctaliaNiri` | `mkNoctaliaNiri "volume increase"` | `["noctalia-shell" "ipc" "call" "volume" "increase"]` |
| `config.flake.lib.mkNoctaliaHypr` | `mkNoctaliaHypr "volume increase"` | `"exec, noctalia-shell ipc call volume increase"` |

---

## Dev

### Editors

| Module | Side | Packages | Sets |
|--------|------|----------|------|
| `helix` | HM | — | `EDITOR=hx`, `VISUAL=hx` (mkDefault), mimeApps text/* → helix, `clipboard-provider` (mkDefault wayland) |
| `zed` | HM | zed-editor-fhs | `VISUAL=zeditor --wait` (overrides helix default) |

> Servers set `programs.helix.settings.editor.clipboard-provider = "termcode"` in their
> host `homeModule` so yank/paste works over SSH (OSC 52) where there's no Wayland clipboard.

### Tools

All HM side. Import = enable.

| Module | Packages |
|--------|----------|
| `build` | gnumake, cmake, pkg-config |
| `cli` | jq, yq, sd, just, hyperfine, tokei, watchexec, btop, gh |
| `database` | sqlite, postgresql |
| `direnv` | direnv + nix-direnv |
| `git` | git, delta, lazygit, pre-commit, commitizen, lefthook, tig, git-absorb |
| `network` | httpie, bandwhich |
| `opencode` | opencode (from inputs), MCP integration, custom agents |
| `security` | nmap, netcat, mtr, tcpdump, traceroute |

### Languages

All HM side. Import = enable.

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
| `core` | nixos | systemd-boot, Plymouth, Nix flakes/GC/auto-optimise, NetworkManager, nix-ld, **all substituters/caches** (cache.nixos.org, nix-community, niri-nix, noctalia, hyprland, lantian, kopuz) |
| `core` | HM | home-manager, XDG base dirs |
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
| `zsh` | nixos + HM | zsh, eza aliases, history, syntax highlighting, fastfetch on login |
| `shellTools` | HM | zoxide, fzf, ripgrep, fd |
| `starship` | HM | Starship prompt (git, nix-shell, python, OS symbol) |
| `ssh` | HM | SSH config + YubiKey FIDO2 identities, ControlMaster multiplexing, host aliases |

---

## Lib

Infrastructure modules — not imported by hosts, wired in automatically.

| File | Purpose |
|------|---------|
| `compositors.nix` | HM module — defines all shared `features.compositors.*` options (monitors, gaps, colors, borders, opacity, cursor, keyboard, terminal) |
| `registry.nix` | Defines `options.registry.hosts` — host registry (username, system, stateVersion, domain, hostId, extraGroups, homeDirectory, **aspects**, **nixosModule**, **homeModule**). Exposes `flake.lib.aspects` (name→name map for the bare form), folds `flake.aspectInclude` keys into the valid-names enum, and resolves the transitive closure of aspects. |

### Aspects (host module selection)

Each host lists its modules once as `registry.hosts.<host>.aspects`. Names route to
whichever layer defines them (`flake.modules.nixos.<name>` → system,
`flake.modules.homeManager.<name>` → home, both → both; nixos-only names are skipped by
the standalone `homeConfigurations` build). Names can also be **aggregators**
(`flake.aspectInclude.<name>` keys) that expand to more names — see Aggregators & Role
Bundles. The option is enum-typed against all module names **plus** all aggregator keys,
so typos fail at eval with the full valid list. Written bare via
`with config.flake.lib.aspects; [ … ]`.

```nix
registry.hosts.nimeses.aspects = with config.flake.lib.aspects; [
  workstation                 # role bundle → base + desktop + niri + …
  hardwareNimeses             # host-only
  gaming performance          # extra profiles
];
```

---

## Deployment (deploy-rs)

`modules/meta/deploy.nix` generates `flake.deploy.nodes` from the registry — one node
per NixOS host (filtered to those with a `nixosConfigurations` entry, so `*Minimal`
variants and finix `icarus` are excluded).

```bash
deploy .#<host>                 # build locally, copy closure, activate remotely
deploy .#<host> --skip-checks   # skip the slow flake-check pre-flight
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
