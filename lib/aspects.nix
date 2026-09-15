{ lib, config, ... }:
let
  inherit (lib)
    any
    attrNames
    concatMapAttrs
    elem
    filter
    filterAttrs
    foldl'
    genAttrs
    hasPrefix
    mapAttrs
    mapAttrs'
    nameValuePair
    optionalAttrs
    recursiveUpdate
    setAttrByPath
    splitString
    ;

  fields = [
    "description"
    "includes"
    "nixos"
    "finix"
    "home"
  ];

  layers = [
    "nixos"
    "finix"
    "home"
  ];

  isAspect = node: node.includes != [ ] || any (l: node.${l} != null) layers;

  flattenFrom =
    prefix: node:
    optionalAttrs (isAspect node) { ${prefix} = node; }
    // concatMapAttrs (k: v: flattenFrom "${prefix}.${k}" v) (removeAttrs node fields);

  features = concatMapAttrs (k: v: flattenFrom k v) config.aspects;

  checkHost =
    name: host:
    let
      isNixos = elem "nixos" host.classes;
    in
    if host.classes == [ ] then
      throw "hosts.${name}: declares no classes, so nothing would be built from it"
    else if isNixos && host.stateVersion == null then
      throw "hosts.${name}: a nixos-class host needs a stateVersion"
    else if !isNixos && host.stateVersion != null then
      throw "hosts.${name}: stateVersion is unused without a nixos class"
    else
      host;

  withPrefix = p: mapAttrs' (n: v: nameValuePair "${p}.${n}" v);

  hosts =
    let
      checked = mapAttrs checkHost config.hosts;
    in
    withPrefix "hosts" (foldl' (acc: n: builtins.seq checked.${n} acc) checked (attrNames checked));
  users = withPrefix "users" config.users;

  reserved = filter (n: hasPrefix "hosts." n || hasPrefix "users." n) (attrNames features);

  all =
    if reserved != [ ] then
      throw ''aspects: "hosts" and "users" are reserved; the feature tree defines ${toString reserved}''
    else
      features // hosts // users;

  kindOf =
    n:
    if hosts ? ${n} then
      "host"
    else if users ? ${n} then
      "user"
    else
      "feature";

  rank = {
    feature = 0;
    user = 1;
    host = 2;
  };

  aspectNames = foldl' (
    acc: n: recursiveUpdate acc (setAttrByPath (splitString "." n) n)
  ) { } (attrNames all);

  nodeAt =
    n: from:
    if all ? ${n} then
      all.${n}
    else
      throw "unknown aspect \"${n}\"${from}";

  includesOf =
    n:
    let
      kind = kindOf n;
    in
    map (
      dep:
      let
        depKind = kindOf (
          if all ? ${dep} then dep else throw ''unknown aspect "${dep}", included by ${n}''
        );
      in
      if rank.${depKind} > rank.${kind} then
        throw "${n} is a ${kind} and may not include ${dep}, which is a ${depKind}"
      else
        dep
    ) (nodeAt n "").includes;

  resolve =
    roots:
    map (e: e.key) (
      builtins.genericClosure {
        startSet = map (n: builtins.seq (nodeAt n " (selected directly)") { key = n; }) roots;
        operator = { key, ... }: map (dep: { key = dep; }) (includesOf key);
      }
    );

  layersOf = n: filter (l: (nodeAt n "").${l} != null) layers;

  modulesFor = genAttrs layers (
    layer: mapAttrs (_: a: a.${layer}) (filterAttrs (_: a: a.${layer} != null) all)
  );

  aspectsFor = layerModules: ns: map (n: layerModules.${n}) (filter (n: layerModules ? ${n}) ns);

  usersOf = host: filter (n: kindOf n == "user") (resolve [ host ]);
in
{
  options.aspectLib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    internal = true;
    description = "Derived views over the three trees.";
  };

  config.aspectLib = {
    inherit
      all
      aspectNames
      kindOf
      rank
      fields
      layers
      resolve
      layersOf
      modulesFor
      aspectsFor
      usersOf
      ;
    allNames = attrNames all;
    hostNames = attrNames hosts;
    userNames = attrNames users;
  };
}
