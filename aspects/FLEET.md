<!-- GENERATED FILE - DO NOT EDIT.
     Source of truth is `hosts` and `users`.
     Regenerate with:  nix build --file . packages.docs && cp result/*.md aspects/
     `checks.docs` fails if this file drifts from the config. -->

# Fleet

8 hosts, 7 users.

Hosts and users are aspects too: a host subscribes an account by including it, and
may inherit another host the same way. Both are selectable by name.

## Hosts

| Host | Classes | Users | Aspects | Description |
|------|---------|-------|--------:|-------------|
| `athena` | nixos | `athena` | 29 | Tailnet server: DNS, password vault, monitoring and file drop. |
| `atlas` | nixos | `atlas` | 37 | Public-facing server: forgejo, binary cache, media, identity and matrix. |
| `bellerophon` | finix | `icarus` | 47 | finix test laptop, exercising the busybox/iwd/mdevd/seatd branch of the matrix. |
| `hermes` | nixos | `hermes` | 34 | Rescue and installer stick; persists its own passwords and doubles as recovery. |
| `icarus` | finix | `icarus` | 46 | finix laptop on niri, second daily driver. |
| `nimeses` | finix | `nimeses` | 50 | finix laptop on umbriel, the primary daily driver. |
| `phaethon` | finix | `phaethon` | 28 | finix server: ZFS storage and docker workloads, no desktop. |
| `prometheus` | nixos | `prometheus` | 50 | NixOS desktop workstation: gaming, virtualisation and heavy builds. |

## Users

| User | Description | Includes |
|------|-------------|----------|
| `athena` | Admin account on athena. | `bundle.cliEnv` `dev.tools.network` `desktop.apps.fastfetch` |
| `atlas` | Admin account on atlas. | `bundle.cliEnv` `dev.tools.network` `desktop.apps.fastfetch` |
| `hermes` | Recovery account; carries a graphical session so the stick is usable by hand. | `bundle.cliEnv` `bundle.services` `desktop.compositors.umbriel` `desktop.noctalia` `desktop.apps.term.foot` `desktop.apps.yaziFilechooser` `desktop.apps.browser.glide` |
| `icarus` | Daily account on icarus and bellerophon. | `bundle.cliEnv` `desktop.compositors.niri` `bundle.desktop` `dev.languages.nix` `shell.ssh` `desktop.apps.term.foot` `dev.editors.zed` |
| `nimeses` | Primary account: full desktop and the nix/rust/python toolchains. | `bundle.cliEnv` `bundle.desktop` `desktop.compositors.umbriel` `dev.languages.nix` `dev.editors.zed` `desktop.apps.term.kitty` `desktop.apps.browser.glide` `dev.languages.python` `dev.languages.rust` `dev.languages.markdown` `dev.tools.direnv` |
| `phaethon` | Admin account on phaethon. | `bundle.cliEnv` `dev.tools.network` `dev.languages.nix` `desktop.apps.fastfetch` |
| `prometheus` | Workstation account: full desktop, every language toolchain and build tooling. | `bundle.cliEnv` `bundle.desktop` `desktop.compositors.niri` `desktop.compositors.umbriel` `dev.languages.nix` `dev.editors.zed` `desktop.apps.term.kitty` `desktop.apps.browser.glide` `dev.languages.c` `dev.languages.python` `dev.languages.rust` `dev.languages.markdown` `dev.tools.build` `dev.tools.direnv` |
