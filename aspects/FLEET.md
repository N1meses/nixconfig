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
| `bellerophon` | finix | `icarus` | 47 | finix laptop with busybox/iwd/mdevd/seatd, part of the finix test matrix. |
| `hermes` | nixos | `hermes` | 33 | impermanent host and installer for quick access |
| `icarus` | finix | `icarus` | 46 | finix laptop on niri part of the test matrix for finix |
| `nimeses` | finix | `nimeses` | 50 | finix laptop on umbriel also my daily driver |
| `phaethon` | finix | `phaethon` | 28 | finix server with ZFS storage and docker, part of the finix test matrix |
| `prometheus` | nixos | `prometheus` | 49 | NixOS desktop workstation and gaming |

## Users

| User | Description | Includes |
|------|-------------|----------|
| `athena` | Admin account on athena. | `bundle.cliEnv` `dev.tools.network` `desktop.apps.fastfetch` |
| `atlas` | Admin account on atlas. | `bundle.cliEnv` `dev.tools.network` `desktop.apps.fastfetch` |
| `hermes` | acc for hermes | `bundle.cliEnv` `bundle.services` `desktop.compositors.umbriel` `desktop.noctalia` `desktop.apps.term.foot` `desktop.apps.yaziFilechooser` `desktop.apps.browser.glide` |
| `icarus` | Daily account on icarus and bellerophon. | `bundle.cliEnv` `desktop.compositors.niri` `bundle.desktop` `dev.languages.nix` `shell.ssh` `desktop.apps.term.foot` `dev.editors.zed` |
| `nimeses` | user for daily | `bundle.cliEnv` `bundle.desktop` `desktop.compositors.umbriel` `dev.languages.nix` `dev.editors.zed` `desktop.apps.term.kitty` `desktop.apps.browser.glide` `dev.languages.python` `dev.languages.rust` `dev.languages.markdown` `dev.tools.direnv` |
| `phaethon` | Admin account on phaethon. | `bundle.cliEnv` `dev.tools.network` `dev.languages.nix` `desktop.apps.fastfetch` |
| `prometheus` | user for prometheus | `bundle.cliEnv` `bundle.desktop` `desktop.compositors.niri` `desktop.compositors.umbriel` `dev.languages.nix` `dev.editors.zed` `desktop.apps.term.kitty` `desktop.apps.browser.glide` `dev.languages.c` `dev.languages.python` `dev.languages.rust` `dev.languages.markdown` `dev.tools.build` `dev.tools.direnv` |
