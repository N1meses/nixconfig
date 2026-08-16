<!-- GENERATED FILE - DO NOT EDIT.
     Source of truth is `config.aspects` / `config.registry`.
     Regenerate with:  nix build --file . packages.docs && cp result/MODULES.md modules/MODULES.md
     `checks.docs` fails if this file drifts from the config. -->

# Module Library

119 aspects, 8 hosts.

## Hosts

| Host | Class | Users | Aspects | Domain |
|------|-------|-------|--------:|--------|
| `athena` | nixos | `athena` | 27 | athena.tail4109e2.ts.net |
| `atlas` | nixos | `atlas` | 34 | nimeses.com |
| `bellerophon` | finix | `icarus` | 44 | - |
| `hermes` | nixos | `hermes` | 32 | - |
| `icarus` | finix | `icarus` | 43 | - |
| `nimeses` | finix | `nimeses` | 52 | - |
| `phaethon` | finix | `phaethon` | 25 | - |
| `prometheus` | nixos | `prometheus` | 48 | - |

## Aspects

An aspect declares any subset of the layer slots `nixos`, `finix`, `home`, plus an
optional `includes` list. A host names it once; the builder routes it to whichever
slots it defines. An aspect with no slots at all is an aggregator - it exists only
to pull in the names it includes.

| Aspect | Layers | Description | Includes |
|--------|--------|-------------|----------|
| `bundle.apps` | *aggregator* | Everyday graphical apps: file manager, browser, GTK theming, nh and fastfetch. | `desktop.apps.yazi` `desktop.apps.browser` `desktop.apps.gtk` `desktop.apps.nh` `desktop.apps.fastfetch` |
| `bundle.base` | *aggregator* | Baseline every host gets: nix settings, locale, user accounts and tailscale. | `core.core` `core.local` `core.users` `server.vpn.tailscale` |
| `bundle.cliEnv` | *aggregator* | Interactive shell environment: shell, file manager, editor, CLI tools and git. | `core.core` `bundle.shell` `desktop.apps.yazi` `dev.editors.helix` `dev.tools.cli` `dev.tools.git` |
| `bundle.desktop` | *aggregator* | Graphical desktop bundle: session services, apps and the noctalia shell. | `bundle.services` `bundle.apps` `desktop.apps.yaziFilechooser` `desktop.noctalia` |
| `bundle.server` | *aggregator* | Headless server role: base plus CLI environment, hardened sshd, networking tools and nh. | `bundle.base` `bundle.cliEnv` `server.serverCore` `server.sshd` `dev.tools.network` `desktop.apps.nh` |
| `bundle.services` | *aggregator* | Desktop plumbing every graphical session needs: graphics, fonts, portals, audio, bluetooth and user services. | `desktop.services.graphics` `desktop.services.fonts` `desktop.services.portals` `desktop.services.audio` `desktop.services.bluetooth` `desktop.services.userServices` |
| `bundle.shell` | *aggregator* | Shell stack: zsh, fzf/zoxide tooling, the starship prompt and ssh client config. | `shell.zsh` `shell.shellTools` `shell.starship` `shell.ssh` |
| `bundle.workstation` | *aggregator* | Full graphical workstation: base plus CLI environment, desktop, niri, display manager and editors. | `bundle.base` `bundle.cliEnv` `bundle.desktop` `desktop.compositors.niri` `desktop.services.ly` `dev.languages.nix` `dev.tools.nixIndex` `dev.editors.zed` `desktop.apps.term.kitty` |
| `core.cachyosKernel` | nixos | CachyOS performance kernel, via the pinned overlay. | - |
| `core.core` | nixos+finix+home | Core system settings: nix daemon config, boot defaults and the baseline package set. | - |
| `core.finitV5` | finix | Pins finit to v5 with a matching libconfuse build. | - |
| `core.local` | nixos+finix | Locale, timezone, console keymap and i18n settings. | - |
| `core.overlays` | nixos | Fleet-wide nixpkgs overlays (pinned CachyOS kernel). | - |
| `core.persistence` | finix | Declarative /persist bind-mount handling for impermanent finix roots. | - |
| `core.sops` | nixos | sops-nix secret decryption, keyed on an age keyfile at /root/.config/sops/age/keys.txt. | - |
| `core.users` | nixos+finix | Materialises registry.users into real accounts on whichever layer the host builds in. | - |
| `desktop.apps.browser` | home | Web browser with declarative policy and default-application wiring. | - |
| `desktop.apps.fastfetch` | home | fastfetch system summary, configured for this fleet. | - |
| `desktop.apps.fuzzel` | home | The fuzzel application launcher, themed. | `desktop.compositors.compositors` |
| `desktop.apps.gtk` | home | GTK theme, cursor and icon settings. | - |
| `desktop.apps.nh` | nixos | nh, the nix helper CLI for rebuilds and garbage collection. | - |
| `desktop.apps.term.foot` | home | The foot terminal emulator. | `desktop.compositors.compositors` |
| `desktop.apps.term.ghostty` | home | The ghostty terminal emulator. | `desktop.compositors.compositors` |
| `desktop.apps.term.kitty` | home | The kitty terminal emulator. | `desktop.compositors.compositors` |
| `desktop.apps.yazi` | home | The yazi terminal file manager. | - |
| `desktop.apps.yaziFilechooser` | home | yazi wired up as the xdg-desktop-portal file chooser, via termfilechooser. | `desktop.apps.yazi` `desktop.compositors.compositors` `desktop.services.portals` |
| `desktop.compositors.compositors` | home | Shared option surface every compositor implements: keybinds, monitors, autostart, terminal and launcher. | - |
| `desktop.compositors.halley` | finix+home | The halley Wayland compositor. | `desktop.compositors.compositors` `desktop.services.portals` |
| `desktop.compositors.hyprland` | nixos+home | The Hyprland Wayland compositor. | `desktop.compositors.compositors` `desktop.services.portals` |
| `desktop.compositors.mango` | nixos+home | The mango Wayland compositor. | `desktop.compositors.compositors` `desktop.services.portals` |
| `desktop.compositors.niri` | nixos+finix+home | The niri scrolling Wayland compositor, with keybinds and portal wiring. | `desktop.compositors.compositors` `desktop.services.portals` |
| `desktop.noctalia` | home | The noctalia desktop shell (bar, launcher, control centre). | `desktop.compositors.compositors` |
| `desktop.noctaliaSettings` | home | Declarative noctalia settings, generated per host. | - |
| `desktop.services.audio` | nixos+finix | PipeWire audio with ALSA and 32-bit support. | - |
| `desktop.services.bluetooth` | nixos+finix | Bluetooth stack, powered on at boot. | - |
| `desktop.services.fonts` | nixos+finix | System font packages and fontconfig. | - |
| `desktop.services.graphics` | nixos | GPU drivers and the X server fallback. | - |
| `desktop.services.greetd` | nixos+finix | greetd display manager with the tuigreet frontend. | - |
| `desktop.services.ly` | nixos+finix | ly display manager. | - |
| `desktop.services.mako` | home | mako notification daemon, themed. | `desktop.compositors.compositors` |
| `desktop.services.music` | home | MPD music daemon, in the user session, playing through PipeWire. | `desktop.compositors.compositors` |
| `desktop.services.portals` | nixos+finix+home | xdg-desktop-portal backends and per-compositor backend routing. | - |
| `desktop.services.userServices` | home | Per-user session services: automounting and notifications. | - |
| `desktop.tools.screenshot` | home | Screenshot and screen-recording tools. | - |
| `desktop.tools.wallpaper` | home | Wallpaper daemon and the wallpaper source directory. | `desktop.compositors.compositors` |
| `dev.editors.helix` | home | The Helix editor, with theme and language-server registry. | - |
| `dev.editors.zed` | home | The Zed editor, set as $VISUAL. | - |
| `dev.languages.bash` | home | Bash toolchain and Helix language-server wiring. | - |
| `dev.languages.c` | home | C/C++ toolchain and clangd wiring. | - |
| `dev.languages.css` | home | CSS toolchain and language-server wiring. | - |
| `dev.languages.go` | home | Go toolchain and gopls wiring. | - |
| `dev.languages.html` | home | HTML toolchain and language-server wiring. | - |
| `dev.languages.java` | home | Java toolchain and jdtls wiring. | - |
| `dev.languages.javascript` | home | JavaScript/TypeScript toolchain and language-server wiring. | - |
| `dev.languages.json` | home | JSON toolchain and language-server wiring. | - |
| `dev.languages.lua` | home | Lua toolchain and lua-language-server wiring. | - |
| `dev.languages.markdown` | home | Markdown toolchain and marksman wiring. | - |
| `dev.languages.nix` | home | Nix toolchain, nixd language server and nixfmt formatting. | - |
| `dev.languages.puml` | home | PlantUML tooling. | - |
| `dev.languages.python` | home | Python toolchain and pyright wiring. | - |
| `dev.languages.rust` | home | Rust toolchain and rust-analyzer wiring. | - |
| `dev.languages.yaml` | home | YAML toolchain and language-server wiring. | - |
| `dev.languages.zig` | home | Zig toolchain and zls wiring. | - |
| `dev.tools.build` | home | Build tooling (compilers, make, and friends). | - |
| `dev.tools.cli` | home | General CLI utilities. | - |
| `dev.tools.database` | home | Database client tooling. | - |
| `dev.tools.direnv` | home | direnv with zsh integration. | - |
| `dev.tools.git` | home | git with delta paging and identity from registry.users.<u>.git. | - |
| `dev.tools.network` | home | Network diagnostic tooling. | - |
| `dev.tools.nixIndex` | nixos | nix-index and command-not-found lookup. | - |
| `dev.tools.security` | home | Security and secret-handling tooling. | - |
| `finix.coreutilsBusybox` | finix | Selects busybox as the system coreutils provider. | - |
| `finix.coreutilsGnu` | finix | Selects GNU coreutils as the system coreutils provider. | - |
| `finix.devGardendevd` | finix | Selects gardendevd as the device manager. | - |
| `finix.devMdevd` | finix | Selects mdevd as the device manager. | - |
| `finix.devUdev` | finix | Selects udev as the device manager. | - |
| `finix.doas` | finix | doas privilege escalation for the wheel group. | - |
| `finix.docker` | finix | Docker daemon with syslog wiring. | - |
| `finix.netDhcpcd` | finix | Selects dhcpcd as the network stack. | - |
| `finix.netIwd` | finix | Selects iwd as the network stack. | - |
| `finix.netNM` | finix | Selects NetworkManager as the network stack. | - |
| `finix.seatElogind` | finix | Selects elogind as the seat/session manager. | - |
| `finix.seatSeatd` | finix | Selects seatd as the seat/session manager. | - |
| `finix.session` | finix | finix session wiring: dbus, XDG icon caches, runlevel and PATH linking. | - |
| `finix.zfs` | finix | ZFS filesystem support in initrd and the running system. | - |
| `profile.gaming` | nixos | Gaming stack: Steam, gamemode and the kernel/sysctl tuning they want. | - |
| `profile.laptop` | nixos+finix | Laptop power management, lid handling and backlight control. | - |
| `profile.mkVM` | nixos+finix | Turns a host into a bootable QEMU VM for testing. | - |
| `profile.performance` | nixos | Performance tuning: zram, sysctls and nix daemon scheduling. | - |
| `profile.rescue` | nixos | Recovery toolkit: filesystem support and repair utilities for a broken boot. | - |
| `profile.virtualisation` | nixos+finix | Virtualisation host support: libvirtd + virt-manager on nixos; incus plus per-user session libvirt (qemu:///session, no daemon) on finix. | - |
| `server.binaryCache` | nixos | nix-serve binary cache, published on the tailnet. | `core.sops` |
| `server.forgejoRunner` | nixos | Forgejo Actions runner registered against atlas. | `core.sops` |
| `server.media.jellyfin` | nixos | Jellyfin media server, proxied and backed up. | `server.nginx` `server.security.restic` |
| `server.media.navidrome` | nixos | Navidrome music streaming server. | `server.nginx` `server.security.restic` |
| `server.media.nextcloud` | nixos | Nextcloud with a local database. | `server.nginx` `server.security.restic` `core.sops` |
| `server.media.nixarr` | nixos | The *arr media automation stack. | `server.security.restic` `core.sops` |
| `server.media.ocis` | nixos | ownCloud Infinite Scale. | `server.nginx` `server.security.restic` |
| `server.monitoring` | nixos | netdata metrics, streaming to the parent collector over tailscale. | `core.sops` |
| `server.nginx` | nixos | nginx reverse proxy with ACME-backed TLS. | - |
| `server.security.authentik` | nixos | Authentik identity provider. | `server.nginx` `server.security.restic` `core.sops` |
| `server.security.restic` | nixos | Nightly restic backups with retention pruning. | `core.sops` |
| `server.security.vaultwarden` | nixos | Vaultwarden password manager. | `server.nginx` `server.security.restic` `core.sops` |
| `server.serverCore` | nixos | Server baseline: fail2ban, trimmed documentation and headless defaults. | - |
| `server.share.croc` | nixos | croc file-transfer relay on the tailnet. | - |
| `server.share.element` | nixos | Element web client. | `server.nginx` |
| `server.share.forgejo` | nixos | Forgejo git forge with LFS and Actions. | `server.nginx` `server.security.restic` |
| `server.share.matrix` | nixos | Matrix homeserver. | `server.nginx` `server.security.restic` `core.sops` |
| `server.share.ollama` | nixos | Ollama local LLM server. | - |
| `server.sshd` | nixos+finix | OpenSSH server, key-only and restricted to declared users. | - |
| `server.technitium` | nixos | Technitium DNS server. | - |
| `server.vpn.airvpn` | nixos | AirVPN wireguard tunnel with a sops-held config. | `core.sops` |
| `server.vpn.cloudflared` | nixos | Cloudflare tunnel exposing declared nginx vhosts publicly. | `server.nginx` `core.sops` |
| `server.vpn.mullvad` | nixos | Mullvad VPN client. | - |
| `server.vpn.tailscale` | nixos+finix | Tailscale mesh VPN, trusted in the firewall. | - |
| `shell.shellTools` | home | fzf and zoxide, integrated into zsh. | - |
| `shell.ssh` | home | ssh client config and per-host match blocks. | - |
| `shell.starship` | home | The starship prompt, themed. | - |
| `shell.zsh` | nixos+finix+home | zsh as the login shell, with autosuggestions and completion. | - |
