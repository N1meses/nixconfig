<!-- GENERATED FILE — DO NOT EDIT.
     Source of truth is `config.aspects` / `config.registry`.
     Regenerate with:  nix build --file . packages.docs && cp result/MODULES.md modules/MODULES.md
     `checks.docs` fails if this file drifts from the config. -->

# Module Library

118 aspects, 8 hosts.

## Hosts

| Host | Class | Users | Aspects | Domain |
|------|-------|-------|--------:|--------|
| `athena` | nixos | `athena` | 30 | athena.tail4109e2.ts.net |
| `atlas` | nixos | `atlas` | 37 | nimeses.com |
| `bellerophon` | finix | `icarus` | 43 | — |
| `hermes` | nixos | `hermes` | 32 | — |
| `icarus` | finix | `icarus` | 42 | — |
| `nimeses` | finix | `nimeses` | 50 | — |
| `phaethon` | finix | `phaethon` | 27 | — |
| `prometheus` | nixos | `prometheus` | 49 | — |

## Aspects

An aspect declares any subset of the layer slots `nixos`, `finix`, `home`, plus an
optional `includes` list. A host names it once; the builder routes it to whichever
slots it defines. An aspect with no slots at all is an aggregator — it exists only
to pull in the names it includes.

| Aspect | Layers | Description | Includes |
|--------|--------|-------------|----------|
| `airvpn` | nixos | AirVPN wireguard tunnel with a sops-held config. | `sops` |
| `apps` | *aggregator* | Everyday graphical apps: file manager, browser, GTK theming, nh and fastfetch. | `yazi` `browser` `gtk` `nh` `fastfetch` |
| `audio` | nixos+finix | PipeWire audio with ALSA and 32-bit support. | — |
| `authentik` | nixos | Authentik identity provider. | `nginx` `restic` `sops` |
| `base` | *aggregator* | Baseline every host gets: nix settings, locale, user accounts, tailscale and privilege escalation. | `core` `local` `users` `tailscale` `doas` |
| `bash` | home | Bash toolchain and Helix language-server wiring. | — |
| `binaryCache` | nixos | nix-serve binary cache, published on the tailnet. | `sops` |
| `bluetooth` | nixos+finix | Bluetooth stack, powered on at boot. | — |
| `browser` | home | Web browser with declarative policy and default-application wiring. | — |
| `build` | home | Build tooling (compilers, make, and friends). | — |
| `c` | home | C/C++ toolchain and clangd wiring. | — |
| `cachyosKernel` | nixos | CachyOS performance kernel, via the pinned overlay. | — |
| `cli` | home | General CLI utilities. | — |
| `cliEnv` | *aggregator* | Interactive shell environment: shell, file manager, editor, CLI tools and git. | `core` `shell` `yazi` `helix` `cli` `git` |
| `cloudflared` | nixos | Cloudflare tunnel exposing declared nginx vhosts publicly. | `nginx` `sops` |
| `compositors` | home | Shared option surface every compositor implements: keybinds, monitors, autostart, terminal and launcher. | — |
| `core` | nixos+finix+home | Core system settings: nix daemon config, boot defaults and the baseline package set. | — |
| `coreutilsBusybox` | finix | Selects busybox as the system coreutils provider. | — |
| `coreutilsGnu` | finix | Selects GNU coreutils as the system coreutils provider. | — |
| `croc` | nixos | croc file-transfer relay on the tailnet. | — |
| `css` | home | CSS toolchain and language-server wiring. | — |
| `database` | home | Database client tooling. | — |
| `desktop` | *aggregator* | Graphical desktop bundle: session services, apps, the noctalia shell and session wiring. | `services` `apps` `noctalia` `session` |
| `devGardendevd` | finix | Selects gardendevd as the device manager. | — |
| `devMdevd` | finix | Selects mdevd as the device manager. | — |
| `devUdev` | finix | Selects udev as the device manager. | — |
| `direnv` | home | direnv with zsh integration. | — |
| `doas` | finix | doas privilege escalation for the wheel group. | — |
| `docker` | finix | Docker daemon with syslog wiring. | — |
| `element` | nixos | Element web client. | `nginx` |
| `fastfetch` | home | fastfetch system summary, configured for this fleet. | — |
| `finitV5` | finix | Pins finit to v5 with a matching libconfuse build. | — |
| `fonts` | nixos+finix | System font packages and fontconfig. | — |
| `foot` | home | The foot terminal emulator. | `compositors` |
| `forgejo` | nixos | Forgejo git forge with LFS and Actions. | `nginx` `restic` |
| `forgejoRunner` | nixos | Forgejo Actions runner registered against atlas. | `sops` |
| `fuzzel` | home | The fuzzel application launcher, themed. | `compositors` |
| `gaming` | nixos | Gaming stack: Steam, gamemode and the kernel/sysctl tuning they want. | — |
| `ghostty` | home | The ghostty terminal emulator. | `compositors` |
| `git` | home | git with delta paging and identity from registry.users.<u>.git. | — |
| `go` | home | Go toolchain and gopls wiring. | — |
| `graphics` | nixos | GPU drivers and the X server fallback. | — |
| `greetd` | nixos+finix | greetd display manager with the tuigreet frontend. | — |
| `gtk` | home | GTK theme, cursor and icon settings. | — |
| `halley` | finix+home | The halley Wayland compositor. | `compositors` `portals` |
| `helix` | home | The Helix editor, with theme and language-server registry. | — |
| `html` | home | HTML toolchain and language-server wiring. | — |
| `hyprland` | nixos+home | The Hyprland Wayland compositor. | `compositors` `portals` |
| `java` | home | Java toolchain and jdtls wiring. | — |
| `javascript` | home | JavaScript/TypeScript toolchain and language-server wiring. | — |
| `jellyfin` | nixos | Jellyfin media server, proxied and backed up. | `nginx` `restic` |
| `json` | home | JSON toolchain and language-server wiring. | — |
| `kitty` | home | The kitty terminal emulator. | `compositors` |
| `laptop` | nixos+finix | Laptop power management, lid handling and backlight control. | — |
| `local` | nixos+finix | Locale, timezone, console keymap and i18n settings. | — |
| `lua` | home | Lua toolchain and lua-language-server wiring. | — |
| `ly` | nixos+finix | ly display manager. | — |
| `mako` | home | mako notification daemon, themed. | `compositors` |
| `mango` | nixos+home | The mango Wayland compositor. | `compositors` `portals` |
| `markdown` | home | Markdown toolchain and marksman wiring. | — |
| `matrix` | nixos | Matrix homeserver. | `nginx` `restic` `sops` |
| `mkVM` | nixos+finix | Turns a host into a bootable QEMU VM for testing. | — |
| `monitoring` | nixos | netdata metrics, streaming to the parent collector over tailscale. | `sops` |
| `mullvad` | nixos | Mullvad VPN client. | — |
| `music` | nixos | MPD music daemon. | — |
| `navidrome` | nixos | Navidrome music streaming server. | `nginx` `restic` |
| `netDhcpcd` | finix | Selects dhcpcd as the network stack. | — |
| `netIwd` | finix | Selects iwd as the network stack. | — |
| `netNM` | finix | Selects NetworkManager as the network stack. | — |
| `network` | home | Network diagnostic tooling. | — |
| `nextcloud` | nixos | Nextcloud with a local database. | `nginx` `restic` `sops` |
| `nginx` | nixos | nginx reverse proxy with ACME-backed TLS. | — |
| `nh` | nixos | nh, the nix helper CLI for rebuilds and garbage collection. | — |
| `niri` | nixos+finix+home | The niri scrolling Wayland compositor, with keybinds and portal wiring. | `compositors` `portals` |
| `nix` | home | Nix toolchain, nixd language server and nixfmt formatting. | — |
| `nixIndex` | nixos | nix-index and command-not-found lookup. | — |
| `nixarr` | nixos | The *arr media automation stack. | `restic` `sops` |
| `noctalia` | home | The noctalia desktop shell (bar, launcher, control centre). | `compositors` |
| `noctaliaSettings` | home | Declarative noctalia settings, generated per host. | — |
| `ocis` | nixos | ownCloud Infinite Scale. | `nginx` `restic` |
| `ollama` | nixos | Ollama local LLM server. | — |
| `overlays` | nixos | Fleet-wide nixpkgs overlays (pinned CachyOS kernel). | — |
| `performance` | nixos | Performance tuning: zram, sysctls and nix daemon scheduling. | — |
| `persistence` | finix | Declarative /persist bind-mount handling for impermanent finix roots. | — |
| `portals` | nixos+finix+home | xdg-desktop-portal backends and per-compositor backend routing. | — |
| `puml` | home | PlantUML tooling. | — |
| `python` | home | Python toolchain and pyright wiring. | — |
| `rescue` | nixos | Recovery toolkit: filesystem support and repair utilities for a broken boot. | — |
| `restic` | nixos | Nightly restic backups with retention pruning. | `sops` |
| `rust` | home | Rust toolchain and rust-analyzer wiring. | — |
| `screenshot` | home | Screenshot and screen-recording tools. | — |
| `seatElogind` | finix | Selects elogind as the seat/session manager. | — |
| `seatSeatd` | finix | Selects seatd as the seat/session manager. | — |
| `security` | home | Security and secret-handling tooling. | — |
| `server` | home | Headless server role: base plus CLI environment, hardened sshd, networking tools and nh. | `base` `cliEnv` `serverCore` `sshd` `network` `nh` |
| `serverCore` | nixos | Server baseline: fail2ban, trimmed documentation and headless defaults. | — |
| `services` | *aggregator* | Desktop plumbing every graphical session needs: graphics, fonts, portals, audio, bluetooth and user services. | `graphics` `fonts` `portals` `audio` `bluetooth` `userServices` |
| `session` | finix | finix session wiring: dbus, XDG icon caches, runlevel and PATH linking. | — |
| `shell` | *aggregator* | Shell stack: zsh, fzf/zoxide tooling, the starship prompt and ssh client config. | `zsh` `shellTools` `starship` `ssh` |
| `shellTools` | home | fzf and zoxide, integrated into zsh. | — |
| `sops` | nixos | sops-nix secret decryption, keyed on an age keyfile at /root/.config/sops/age/keys.txt. | — |
| `ssh` | home | ssh client config and per-host match blocks. | — |
| `sshd` | nixos+finix | OpenSSH server, key-only and restricted to declared users. | — |
| `starship` | home | The starship prompt, themed. | — |
| `tailscale` | nixos+finix | Tailscale mesh VPN, trusted in the firewall. | — |
| `technitium` | nixos | Technitium DNS server. | — |
| `userServices` | home | Per-user session services: automounting and notifications. | — |
| `users` | nixos+finix | Materialises registry.users into real accounts on whichever layer the host builds in. | — |
| `vaultwarden` | nixos | Vaultwarden password manager. | `nginx` `restic` `sops` |
| `virtualisation` | nixos+finix | Virtualisation host support (libvirt/qemu on nixos, incus on finix). | — |
| `wallpaper` | home | Wallpaper daemon and the wallpaper source directory. | `compositors` |
| `workstation` | *aggregator* | Full graphical workstation: base plus CLI environment, desktop, niri, display manager and editors. | `base` `cliEnv` `desktop` `niri` `ly` `nix` `nixIndex` `zed` `kitty` |
| `yaml` | home | YAML toolchain and language-server wiring. | — |
| `yazi` | home | The yazi terminal file manager, wired as the portal file chooser. | `compositors` `portals` |
| `zed` | home | The Zed editor, set as $VISUAL. | — |
| `zfs` | finix | ZFS filesystem support in initrd and the running system. | — |
| `zig` | home | Zig toolchain and zls wiring. | — |
| `zsh` | nixos+finix+home | zsh as the login shell, with autosuggestions and completion. | — |

## Inert selections

Aspects a host selects that contribute nothing to it, because they define no slot
for that host's class. These are dropped silently at `options/aspects.nix`.

| Host | Aspect | Defined for |
|------|--------|-------------|
| `athena` | `doas` | finix |
| `atlas` | `doas` | finix |
| `bellerophon` | `graphics` | nixos |
| `bellerophon` | `nh` | nixos |
| `hermes` | `doas` | finix |
| `icarus` | `graphics` | nixos |
| `icarus` | `nh` | nixos |
| `nimeses` | `graphics` | nixos |
| `nimeses` | `nh` | nixos |
| `prometheus` | `doas` | finix |
| `prometheus` | `session` | finix |

## Undocumented

None — every aspect carries a description.
