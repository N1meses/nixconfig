{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config.aspectLib) layersOf;

  aspectNames = lib.sort lib.lessThan config.aspectLib.flatNames;
  hostNames = lib.sort lib.lessThan (builtins.attrNames config.registry.hosts);

  code = s: "`" + s + "`";
  joinCode = xs: if xs == [ ] then "-" else lib.concatMapStringsSep " " code xs;
  cell = s: if s == null || s == "" then "-" else s;

  hostRow =
    n:
    let
      h = config.registry.hosts.${n};
      r = config.resolved.${n};
    in
    "| ${code n} | ${r.class}${lib.optionalString (h.machineModules == [ ]) " *(image-only)*"} | "
    + "${joinCode h.users} | ${toString r.aspectCount} | ${cell h.domain} |";

  aspectRow =
    n:
    let
      a = config.aspectLib.all.${n};
      ls = layersOf n;
    in
    "| ${code n} | ${if ls == [ ] then "*aggregator*" else lib.concatStringsSep "+" ls} | "
    + "${cell a.description} | ${joinCode a.includes} |";

  modulesMd = ''
    <!-- GENERATED FILE - DO NOT EDIT.
         Source of truth is `config.aspects` / `config.registry`.
         Regenerate with:  nix build --file . packages.docs && cp result/MODULES.md modules/MODULES.md
         `checks.docs` fails if this file drifts from the config. -->

    # Module Library

    ${toString (builtins.length aspectNames)} aspects, ${toString (builtins.length hostNames)} hosts.

    ## Hosts

    | Host | Class | Users | Aspects | Domain |
    |------|-------|-------|--------:|--------|
    ${lib.concatStringsSep "\n" (map hostRow hostNames)}

    ## Aspects

    An aspect declares any subset of the layer slots `nixos`, `finix`, `home`, plus an
    optional `includes` list. A host names it once; the builder routes it to whichever
    slots it defines. An aspect with no slots at all is an aggregator - it exists only
    to pull in the names it includes.

    | Aspect | Layers | Description | Includes |
    |--------|--------|-------------|----------|
    ${lib.concatStringsSep "\n" (map aspectRow aspectNames)}
  '';
in
{
  packages.docs = pkgs.runCommand "nixconfig-docs" { } ''
    mkdir -p "$out"
    cp ${pkgs.writeText "MODULES.md" modulesMd} "$out/MODULES.md"
  '';

  checks.docs = pkgs.runCommand "check-docs-current" { } ''
    if diff -u ${../MODULES.md} ${pkgs.writeText "MODULES.md" modulesMd}; then
      touch "$out"
    else
      echo
      echo "modules/MODULES.md is stale. Regenerate:"
      echo "  nix build --file . packages.docs && cp result/MODULES.md modules/MODULES.md"
      exit 1
    fi
  '';
}
