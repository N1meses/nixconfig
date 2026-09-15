{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config.aspectLib)
    all
    allNames
    kindOf
    layersOf
    resolve
    usersOf
    ;

  sorted = lib.sort lib.lessThan;
  namesOfKind = k: sorted (lib.filter (n: kindOf n == k) allNames);

  features = namesOfKind "feature";
  hosts = namesOfKind "host";
  users = namesOfKind "user";

  code = s: "`" + s + "`";
  joinCode = xs: if xs == [ ] then "-" else lib.concatMapStringsSep " " code xs;
  cell = s: if s == null || s == "" then "-" else s;

  hostRow =
    n:
    let
      h = all.${n};
    in
    "| ${code (lib.removePrefix "hosts." n)} "
    + "| ${lib.concatStringsSep "+" h.classes}${lib.optionalString (h.machineModules == [ ]) " *(image-only)*"} "
    + "| ${joinCode (map (lib.removePrefix "users.") (usersOf n))} "
    + "| ${toString (builtins.length (resolve [ n ]))} "
    + "| ${cell h.description} |";

  userRow =
    n:
    let
      u = all.${n};
    in
    "| ${code (lib.removePrefix "users." n)} | ${cell u.description} | ${joinCode u.includes} |";

  featureRow =
    n:
    let
      a = all.${n};
      ls = layersOf n;
    in
    "| ${code n} | ${if ls == [ ] then "*aggregator*" else lib.concatStringsSep "+" ls} "
    + "| ${cell a.description} | ${joinCode a.includes} |";

  table = header: sep: rows: lib.concatStringsSep "\n" ([ header sep ] ++ rows);

  modulesMd = ''
    <!-- GENERATED FILE - DO NOT EDIT.
         Source of truth is `aspects`.
         Regenerate with:  nix build --file . packages.docs && cp result/*.md aspects/
         `checks.docs` fails if this file drifts from the config. -->

    # Module Library

    ${toString (builtins.length features)} aspects.

    An aspect declares any subset of the layer slots `nixos`, `finix`, `home`, plus an
    optional `includes` list. A host names it once; the builder routes it to whichever
    slots it defines. An aspect with no slots at all is an aggregator - it exists only
    to pull in the names it includes.

    ${table "| Aspect | Layers | Description | Includes |" "|--------|--------|-------------|----------|" (map featureRow features)}
  '';

  fleetMd = ''
    <!-- GENERATED FILE - DO NOT EDIT.
         Source of truth is `hosts` and `users`.
         Regenerate with:  nix build --file . packages.docs && cp result/*.md aspects/
         `checks.docs` fails if this file drifts from the config. -->

    # Fleet

    ${toString (builtins.length hosts)} hosts, ${toString (builtins.length users)} users.

    Hosts and users are aspects too: a host subscribes an account by including it, and
    may inherit another host the same way. Both are selectable by name.

    ## Hosts

    ${table "| Host | Classes | Users | Aspects | Description |" "|------|---------|-------|--------:|-------------|" (map hostRow hosts)}

    ## Users

    ${table "| User | Description | Includes |" "|------|-------------|----------|" (map userRow users)}
  '';

  render = name: text: pkgs.writeText name text;

  stale = name: current: generated: ''
    if diff -u ${current} ${generated}; then
      echo "${name} ok"
    else
      echo
      echo "aspects/${name} is stale. Regenerate:"
      echo "  nix build --file . packages.docs && cp result/*.md aspects/"
      exit 1
    fi
  '';
in
{
  packages.docs = pkgs.runCommand "nixconfig-docs" { } ''
    mkdir -p "$out"
    cp ${render "MODULES.md" modulesMd} "$out/MODULES.md"
    cp ${render "FLEET.md" fleetMd} "$out/FLEET.md"
  '';

  checks.docs = pkgs.runCommand "check-docs-current" { } (
    stale "MODULES.md" ../aspects/MODULES.md (render "MODULES.md" modulesMd)
    + stale "FLEET.md" ../aspects/FLEET.md (render "FLEET.md" fleetMd)
    + ''
      touch "$out"
    ''
  );
}
