# Module Library

## File Tree

```
modules/
├── features/
│   ├── base/
│   │   ├── base.nix                  # aggregator → cachyosKernel + local
│   │   ├── cachyOS-kernel.nix        # CachyOS Nix substituters
│   │   ├── homeManager-core.nix      # home-manager, XDG base dirs
│   │   ├── local.nix                 # timezone, locale, keymap
│   │   └── nixos-core.nix            # boot, Nix settings, GC, NetworkManager
│   ├── desktop/
│   │   ├── desktop.nix               # aggregator → services, compositors, noctalia, apps
│   │   ├── apps/
│   │   │   ├── apps.nix              # aggregator → ghostty, yazi, browser, gtk, nh, fastfetch
│   │   │   ├── browser.nix           # brave + MIME associations
│   │   │   ├── fastfetch.nix         # fastfetch with Nix logo
│   │   │   ├── ghostty.nix           # ghostty terminal
│   │   │   ├── gtk.nix               # GTK theme (adw-gtk3, Pop icons)
│   │   │   ├── nh.nix                # nh helper + auto-cleanup
│   │   │   └── yazi.nix              # yazi + xdg-desktop-portal-termfilechooser
│   │   ├── compositors/
│   │   │   ├── compositors.nix       # shared monitor options + wayland tools
│   │   │   ├── hyprland.nix          # Hyprland (nixos + HM)
│   │   │   └── niri.nix              # Niri (nixos + HM)
│   │   ├── noctalia/
│   │   │   ├── noctalia.nix          # noctalia-shell spawn + layer rules
│   │   │   └── noctaliaSettings.nix  # full noctalia config (bar, launcher, etc.)
│   │   └── services/
│   │       ├── services.nix          # aggregator → nixos services + HM userServices
│   │       ├── audio.nix             # PipeWire + WirePlumber + RTKit
│   │       ├── bluetooth.nix         # Bluetooth + Blueman
│   │       ├── fonts.nix             # ibm-plex, google-fonts, nerd-fonts
│   │       ├── graphics.nix          # DRM, modesetting, XKB
│   │       ├── greetd.nix            # tuigreet login manager
│   │       ├── portals.nix           # XDG portal, dbus, udisks2
│   │       └── userServices.nix      # gnome-keyring, udiskie (HM)
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
│   │   ├── tailscale.nix             # Tailscale
│   │   ├── forgejo.nix               # Forgejo git forge
│   │   ├── jellyfin.nix              # Jellyfin media server
│   │   ├── vaultwarden.nix           # Vaultwarden
│   │   ├── croc.nix                  # Croc relay
│   │   ├── cloudflared.nix           # Cloudflare tunnel
│   │   └── ollama.nix                # Ollama + ROCm
│   └── shell/
│       ├── shell.nix                 # aggregator → zsh, shellTools, starship, ssh
│       ├── shell-tools.nix           # zoxide, fzf, ripgrep, fd
│       ├── ssh.nix                   # SSH config + YubiKey FIDO2 identities
│       ├── starship.nix              # Starship prompt
│       └── zsh.nix                   # zsh + eza aliases + fastfetch on login
├── lib/
│   ├── configurations.nix            # host configuration wiring
│   └── registry.nix                  # host registry
├── meta/
│   ├── flake-parts.nix               # flake-parts setup
│   ├── home-generation.nix           # HM generation logic
│   ├── nixos-generation.nix          # NixOS generation logic
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
| `desktop` | nixos + HM | nixos: services, compositors, noctalia · HM: apps, compositors, noctalia, services |
| `apps` | HM | ghostty, yazi, browser, gtk, nh, fastfetch |
| `compositors` | nixos + HM | niri, hyprland |
| `services` | nixos + HM | nixos: graphics, fonts, portals, audio, bluetooth, greetd · HM: userServices |

### Apps

| Module | Side | Packages | Options |
|--------|------|----------|---------|
| `browser` | HM | brave | `features.apps.browser.defaultBrowser` (brave\|firefox\|chromium) |
| `fastfetch` | HM | — | — |
| `ghostty` | HM | ghostty | — |
| `gtk` | HM | adw-gtk3, pop-icon-theme | — |
| `nh` | HM | — | — |
| `yazi` | HM | xdg-desktop-portal-termfilechooser, xdg-terminal-exec | `features.apps.yazi.terminalFilechooser.terminal` (default: ghostty) |

### Compositors

| Module | Side | Options |
|--------|------|---------|
| `niri` | nixos + HM | `features.compositors.niri.enable`, `.extraBinds`, `.autoStart`, `.input.touchpad.enable` |
| `hyprland` | nixos + HM | `features.compositors.hyprland.enable`, `.extraBinds`, `.autoStart`, `.input.touchpad.enable` |
| `compositors` | nixos + HM | `features.compositors.monitors.<name>.{resolution, refreshRate, scale, transform, position, vrr.enable, primary}` |

### Services

| Module | Side | Configures | Options |
|--------|------|------------|---------|
| `audio` | nixos | PipeWire + WirePlumber + RTKit | — |
| `bluetooth` | nixos | Bluetooth + Blueman | — |
| `fonts` | nixos | ibm-plex, google-fonts, material-symbols, nerd-fonts | — |
| `graphics` | nixos | DRM, modesetting, XKB (de) | — |
| `greetd` | nixos | tuigreet, GNOME Keyring PAM | — |
| `portals` | nixos | XDG portal, dbus, udisks2 | — |
| `userServices` | HM | gnome-keyring, udiskie | `features.services.user.storage.udiskie.{notify, automount}` |

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

| Module | Configures | Options |
|--------|------------|---------|
| `serverCore` | Firewall, fail2ban base, lid-switch, no docs, htop/tmux/rsync | — |
| `ssh` | OpenSSH (no root, key-only), fail2ban sshd jail | `features.server.sshPort` (default 22) |
| `nginx` | Nginx + gzip + fail2ban http jails | `features.server.domain` |
| `tailscale` | Tailscale, trusts tailscale0 interface | — |
| `forgejo` | Forgejo (sqlite, LFS, SSH :2222), nginx proxy | — |
| `jellyfin` | Jellyfin, nginx proxy (media.${domain}) | — |
| `vaultwarden` | Vaultwarden (port 8222), nginx proxy, sops env | — |
| `croc` | Croc relay, firewall ports 9009-9013 on tailscale0 | — |
| `cloudflared` | Cloudflare tunnel (forgejo, vault, media) | — |
| `ollama` | Ollama with ROCm (localhost:11434) | — |

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
