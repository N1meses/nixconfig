# Module Library

## File Tree

```
modules/
├── features/
│   ├── base/
│   │   ├── base.nix                  # aggregator → cachyosKernel + local
│   │   ├── cachyosKernel.nix         # CachyOS Nix substituters
│   │   ├── homeManagerCore.nix       # home-manager, XDG base dirs
│   │   ├── local.nix                 # timezone, locale, keymap
│   │   └── nixosCore.nix             # boot, Nix settings, GC, NetworkManager
│   ├── desktop/
│   │   ├── desktop.nix               # aggregator → services, compositors, noctalia, apps
│   │   ├── apps/
│   │   │   ├── apps.nix              # aggregator → ghostty, foot, fuzzel, yazi, browser, gtk, nh, fastfetch
│   │   │   ├── browser.nix           # brave + MIME associations
│   │   │   ├── fastfetch.nix         # fastfetch with Nix logo
│   │   │   ├── foot.nix              # foot terminal
│   │   │   ├── fuzzel.nix            # fuzzel launcher
│   │   │   ├── ghostty.nix           # ghostty terminal
│   │   │   ├── gtk.nix               # GTK theme (adw-gtk3, Pop icons)
│   │   │   ├── nh.nix                # nh helper + auto-cleanup
│   │   │   └── yazi.nix              # yazi + xdg-desktop-portal-termfilechooser
│   │   ├── bar/
│   │   │   └── waybar.nix            # Waybar status bar
│   │   ├── compositors/
│   │   │   ├── compositors.nix       # shared monitor options + wayland tools
│   │   │   ├── hyprland.nix          # Hyprland (nixos + HM)
│   │   │   ├── mango.nix             # Mango (nixos + HM, import = enable)
│   │   │   └── niri.nix              # Niri (nixos + HM)
│   │   ├── noctalia/
│   │   │   ├── noctalia.nix          # noctalia-shell spawn + layer rules + lib functions
│   │   │   └── noctaliaSettings.nix  # full noctalia config (bar, launcher, etc.)
│   │   ├── services/
│   │   │   ├── services.nix          # aggregator → nixos services + HM userServices
│   │   │   ├── audio.nix             # PipeWire + WirePlumber + RTKit
│   │   │   ├── bluetooth.nix         # Bluetooth + Blueman
│   │   │   ├── fonts.nix             # ibm-plex, google-fonts, nerd-fonts
│   │   │   ├── graphics.nix          # DRM, modesetting, XKB
│   │   │   ├── greetd.nix            # tuigreet login manager
│   │   │   ├── mako.nix              # Mako notification daemon (HM)
│   │   │   ├── portals.nix           # XDG portal, dbus, udisks2
│   │   │   └── userServices.nix      # gnome-keyring, udiskie (HM)
│   │   └── tools/
│   │       ├── screenshot.nix        # screenshot tooling
│   │       └── wallpaper.nix         # wallpaper configuration (HM)
│   ├── dev/
│   │   ├── editors/
│   │   │   ├── helix.nix             # helix + EDITOR/VISUAL + mimeApps
│   │   │   └── zed.nix               # zed-editor-fhs + VISUAL override
│   │   ├── languages/                # all HM, import = enable
│   │   │   ├── bash.nix
│   │   │   ├── c.nix
│   │   │   ├── css.nix
│   │   │   ├── go.nix
│   │   │   ├── html.nix
│   │   │   ├── java.nix
│   │   │   ├── javascript.nix        # JS + TS
│   │   │   ├── json.nix
│   │   │   ├── lua.nix
│   │   │   ├── markdown.nix
│   │   │   ├── nix.nix
│   │   │   ├── puml.nix
│   │   │   ├── python.nix
│   │   │   ├── rust.nix
│   │   │   ├── yaml.nix
│   │   │   └── zig.nix
│   │   └── tools/                    # all HM, import = enable
│   │       ├── build.nix             # make, cmake, pkg-config
│   │       ├── cli.nix               # jq, yq, just, gh, btop, etc.
│   │       ├── database.nix          # sqlite, postgresql
│   │       ├── direnv.nix            # direnv + nix-direnv
│   │       ├── git.nix               # git, delta, lazygit, pre-commit
│   │       ├── network.nix           # httpie, bandwhich
│   │       ├── opencode.nix          # opencode + MCP + agents
│   │       └── security.nix          # nmap, netcat, mtr, tcpdump
│   ├── profiles/                     # all nixos, import = enable
│   │   ├── gaming.nix                # Steam, Proton, GameMode, Gamescope
│   │   ├── laptop.nix                # upower, thermald, libinput touchpad
│   │   ├── performance.nix           # TCP tuning, zram, Nix daemon scheduling
│   │   └── virtualisation.nix        # libvirtd, KVM, virt-manager
│   ├── server/                       # all nixos, import = enable
│   │   ├── serverCore.nix            # firewall, fail2ban base, htop/tmux/rsync
│   │   ├── ssh.nix                   # OpenSSH + fail2ban sshd jail
│   │   ├── nginx.nix                 # nginx + fail2ban http jails
│   │   ├── media/
│   │   │   ├── jellyfin.nix          # Jellyfin media server
│   │   │   ├── navidrome.nix         # Navidrome music server
│   │   │   ├── nextcloud.nix         # Nextcloud
│   │   │   └── nixarr.nix            # nixarr arr stack
│   │   ├── security/
│   │   │   ├── authentik.nix         # Authentik SSO
│   │   │   └── vaultwarden.nix       # Vaultwarden password manager
│   │   ├── share/
│   │   │   ├── croc.nix              # Croc relay
│   │   │   ├── element.nix           # Element web client
│   │   │   ├── forgejo.nix           # Forgejo git forge
│   │   │   ├── matrix.nix            # Matrix (Synapse)
│   │   │   └── ollama.nix            # Ollama + ROCm/CUDA
│   │   └── vpn/
│   │       ├── airvpn.nix            # AirVPN (system-wide)
│   │       ├── cloudflared.nix       # Cloudflare tunnel
│   │       ├── mullvad.nix           # Mullvad VPN
│   │       └── tailscale.nix         # Tailscale
│   └── shell/
│       ├── shell.nix                 # aggregator → zsh, shellTools, starship, ssh
│       ├── shellTools.nix            # zoxide, fzf, ripgrep, fd
│       ├── ssh.nix                   # SSH config + YubiKey FIDO2 identities
│       ├── starship.nix              # Starship prompt
│       └── zsh.nix                   # zsh + eza aliases + fastfetch on login
├── lib/
│   ├── compositors.nix               # shared compositor options (monitors, gaps, colors, etc.)
│   ├── configurations.nix            # host configuration wiring
│   └── registry.nix                  # host registry
├── meta/
│   ├── flakeParts.nix                # flake-parts setup
│   ├── homeGeneration.nix            # HM generation logic
│   ├── nixosGeneration.nix           # NixOS generation logic
│   ├── nixpkgs.nix                   # nixpkgs config + overlays
│   ├── overlays.nix                  # package overlays
│   └── users.nix                     # user account definitions
└── MODULES.md                        # this file
```

---

## Desktop

### Aggregators

| Module | Side | Imports |
|--------|------|---------|
| `desktop` | nixos + HM | nixos: services, noctalia · HM: apps, noctalia, services |
| `apps` | HM | ghostty, yazi, browser, gtk, nh, fastfetch |
| `services` | nixos + HM | nixos: graphics, fonts, portals, audio, bluetooth, greetd · HM: userServices |

Compositors (niri, hyprland, mango) are **not** aggregated — each is imported directly by the host.

### Apps

| Module | Side | Packages | Options |
|--------|------|----------|---------|
| `browser` | HM | brave | `features.apps.browser.defaultBrowser` (brave\|firefox\|chromium) |
| `fastfetch` | HM | — | — |
| `foot` | HM | foot | — |
| `fuzzel` | HM | fuzzel | — |
| `ghostty` | HM | ghostty | — |
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
| `fonts` | nixos | ibm-plex, google-fonts, material-symbols, nerd-fonts | — |
| `graphics` | nixos | DRM, modesetting, XKB (de) | — |
| `greetd` | nixos | tuigreet, GNOME Keyring PAM | — |
| `mako` | HM | Mako notification daemon | — |
| `portals` | nixos | XDG portal, dbus, udisks2 | — |
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
| `helix` | HM | — | `EDITOR=hx`, `VISUAL=hx` (mkDefault), mimeApps text/* → helix |
| `zed` | HM | zed-editor-fhs | `VISUAL=zeditor --wait` (overrides helix default) |

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

All nixos side. Import = enable. `features.server.domain` must be set when importing nginx or any service with a reverse proxy.

### Core

| Module | Configures | Options |
|--------|------------|---------|
| `serverCore` | Firewall, fail2ban base, lid-switch, no docs, htop/tmux/rsync | — |
| `ssh` | OpenSSH (no root, key-only), fail2ban sshd jail | `features.server.sshPort` (default 22) |
| `nginx` | Nginx + gzip + fail2ban http jails | `features.server.domain` |

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
| `navidrome` | Navidrome music server, nginx proxy |
| `nextcloud` | Nextcloud, nginx proxy |
| `nixarr` | nixarr arr stack |

### Security (`security/`)

| Module | Configures |
|--------|------------|
| `authentik` | Authentik SSO |
| `vaultwarden` | Vaultwarden (port 8222), nginx proxy, sops env |

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
| `core` (nixos) | nixos | systemd-boot, Plymouth, Nix flakes/cache/GC, NetworkManager |
| `core` (HM) | HM | home-manager, XDG base dirs |
| `base` | nixos | Aggregator: cachyosKernel, local |
| `cachyosKernel` | nixos | CachyOS Nix substituters |
| `local` | nixos | Timezone (Europe/Berlin), locale (en_US / de_DE), keymap (de) |

## Profiles

All nixos side. Import = enable.

| Module | Configures |
|--------|------------|
| `gaming` | Steam, Proton, GameMode, Gamescope, Vulkan, DXVK |
| `laptop` | upower, thermald, power-profiles, libinput touchpad |
| `performance` | TCP tuning, zram (zstd 50%), Nix daemon scheduling |
| `virtualisation` | libvirtd, KVM, virt-manager, KSM, hugepages |

---

## Shell

| Module | Side | Configures |
|--------|------|------------|
| `shell` | nixos + HM | Aggregator: nixos(zsh) · HM(shellTools, starship, zsh, ssh) |
| `zsh` | nixos + HM | zsh, eza aliases, history, syntax highlighting, fastfetch on login |
| `shellTools` | HM | zoxide, fzf, ripgrep, fd |
| `starship` | HM | Starship prompt (git, nix-shell, python, OS symbol) |
| `ssh` | HM | SSH config + YubiKey FIDO2 identities |

---

## Lib

Infrastructure modules — not imported by hosts, wired in automatically.

| File | Purpose |
|------|---------|
| `compositors.nix` | HM module — defines all shared `features.compositors.*` options (monitors, gaps, colors, borders, opacity, cursor, keyboard, terminal) |
| `configurations.nix` | Defines `options.configurations.{nixos,homeManager}` — host configuration wiring |
| `registry.nix` | Defines `options.registry.hosts` — host registry (username, system, stateVersion, extraGroups, homeDirectory) |

---

## Secrets (sops-nix)

Secrets are managed with sops-nix + age keys. Hosts that use secrets import `inputs.sops-nix.nixosModules.sops` directly in their host file.

| Host | Secret file | Age key location |
|------|-------------|-----------------|
| `nimeses` | `secrets/nimeses.yaml` | `/home/nimeses/.config/sops/age/keys.txt` |
| `hephaistos` | `secrets/hephaistos.yaml` | `/root/.config/sops/age/keys.txt` |
| `athena` | `secrets/athena.yaml` | `/root/.config/sops/age/keys.txt` |

Age keys are derived from SSH host keys (YubiKey-backed on nimeses). To add a new secret: encrypt with `sops` and reference via `config.sops.secrets.<name>.path`.
