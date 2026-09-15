<!-- GENERATED FILE - DO NOT EDIT.
     Source of truth is `hosts` and `users`.
     Regenerate with:  nix build --file . packages.docs && cp result/*.md aspects/
     `checks.docs` fails if this file drifts from the config. -->

# Fleet

1 hosts, 1 users.

Hosts and users are aspects too: a host subscribes an account by including it, and
may inherit another host the same way. Both are selectable by name.

## Hosts

| Host | Classes | Users | Aspects | Description |
|------|---------|-------|--------:|-------------|
| `atlas` | nixos *(image-only)* | `nimeses` | 4 | server, forgejo + opencloud |

## Users

| User | Description | Includes |
|------|-------------|----------|
| `nimeses` | primary account | `desktop.term.kitty` |
