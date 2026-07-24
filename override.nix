let
  pinsToml = builtins.fromTOML (builtins.readFile ./.tack/pins.toml);
  lockedPins = builtins.fromJSON (builtins.readFile ./.tack/pins.lock.json);
  shorturls = pinsToml.shorturls or { };

  expandTilde =
    s:
    if builtins.substring 0 2 s == "~/" then
      builtins.getEnv "HOME" + builtins.substring 1 (builtins.stringLength s) s
    else
      s;

  expandShorturl =
    ref:
    let
      m = builtins.match "([A-Za-z][A-Za-z0-9+.-]*):(.*)" ref;
    in
    if m != null && shorturls ? ${builtins.head m} then
      builtins.replaceStrings [ "{path}" ] [ (builtins.elemAt m 1) ] shorturls.${builtins.head m}
    else
      ref;

  isFlakePin =
    name:
    let
      pin = pinsToml.inputs.${name} or { };
    in
    (pin.type or (if pin.flake or true then "flake" else "fetch")) == "flake";

  resolveOverride =
    name: raw:
    let
      src = expandTilde raw;
      fail = msg: throw "TACK_OVERRIDES: ${name}=${raw}: ${msg}";
    in
    if builtins.substring 0 1 src == "/" then
      if !builtins.pathExists src then
        fail "no such directory"
      else if !(isFlakePin name) then
        /. + src
      else if builtins.pathExists (src + "/flake.nix") then
        builtins.getFlake src
      else
        fail "'${name}' is a flake pin but there is no flake.nix there"
    else if builtins.match "[A-Za-z][A-Za-z0-9+.-]*:.*" src != null then
      let
        ref = expandShorturl src;
      in
      if isFlakePin name then builtins.getFlake ref else (builtins.fetchTree ref).outPath
    else
      fail "not an absolute path or a flake ref (/abs/path, gh:owner/repo, github:owner/repo?ref=branch, git+https://...)";

  parseOverride =
    entry:
    let
      m = builtins.match "([^=]+)=(.+)" entry;
      name = builtins.head m;
    in
    if m == null then
      throw "TACK_OVERRIDES: '${entry}' is not of the form pin=source"
    else if !(lockedPins ? ${name}) then
      throw "TACK_OVERRIDES: '${name}' is not a pin. known pins: ${builtins.concatStringsSep " " (builtins.attrNames lockedPins)}"
    else
      {
        inherit name;
        value = resolveOverride name (builtins.elemAt m 1);
      };

  overrides = builtins.listToAttrs (
    map parseOverride (
      builtins.filter (s: builtins.isString s && s != "") (
        builtins.split "[[:space:],]+" (builtins.getEnv "TACK_OVERRIDES")
      )
    )
  );
in
if overrides == { } then
  import ./.tack
else
  builtins.trace
    "tack: overriding inputs: ${builtins.concatStringsSep ", " (builtins.attrNames overrides)}"
    ((import ./.tack) { inherit overrides; })
