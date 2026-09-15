<!-- GENERATED FILE - DO NOT EDIT.
     Source of truth is `aspects`.
     Regenerate with:  nix build --file . packages.docs && cp result/*.md aspects/
     `checks.docs` fails if this file drifts from the config. -->

# Module Library

2 aspects.

An aspect declares any subset of the layer slots `nixos`, `finix`, `home`, plus an
optional `includes` list. A host names it once; the builder routes it to whichever
slots it defines. An aspect with no slots at all is an aggregator - it exists only
to pull in the names it includes.

| Aspect | Layers | Description | Includes |
|--------|--------|-------------|----------|
| `bundle.base` | *aggregator* | Baseline every host gets. | `desktop.term.kitty` |
| `desktop.term.kitty` | home | kitty terminal | - |
