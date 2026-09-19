{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrNames
    concatMap
    filterAttrs
    hasPrefix
    mapAttrsToList
    nameValuePair
    removePrefix
    ;

  inherit (config.aspectLib)
    aspectsFor
    modulesFor
    resolve
    userNames
    ;

  hjem-lib = import "${inputs.hjem}/lib.nix" { inherit lib pkgs; };

  standaloneUser =
    userName:
    lib.evalModules {
      specialArgs = {
        inherit hjem-lib pkgs;
        name = removePrefix "users." userName;
        userEntry = config.aspectLib.all.${userName};
      };
      modules = [
        "${inputs.hjem}/modules/common/user.nix"
        inputs.hjem-rum.hjemModules.default
        { directory = "/home/${removePrefix "users." userName}"; }
      ]
      ++ aspectsFor modulesFor.home (resolve [ userName ]);
    };

  overrides = {
    starship = {
      match = n: n == "starship.toml";
      flags = root: "--set STARSHIP_CONFIG ${root}/starship.toml";
    };
  };

  specFor =
    name: prog:
    let
      o = overrides.${name} or { };
    in
    {
      inherit (prog) package;
      bin = prog.package.meta.mainProgram or name;
      match = o.match or (hasPrefix "${name}/");
      flags = o.flags or (root: "--set XDG_CONFIG_HOME ${root}");
    };

  declared = set: opts: builtins.filter (n: (opts.${n}.enable or null) != null) (attrNames set);

  enabled =
    set: opts:
    builtins.filter (n: set.${n}.enable && (set.${n}.package or null) != null) (declared set opts);

  candidates =
    ev:
    let
      pick =
        group:
        let
          set = ev.config.rum.${group} or { };
          opts = ev.options.rum.${group} or { };
        in
        lib.genAttrs (enabled set opts) (n: specFor n set.${n});
    in
    pick "programs" // pick "desktops";

  filesFor =
    user: spec: filterAttrs (n: f: f.enable && f.source != null && spec.match n) user.xdg.config.files;

  wrap =
    user: userName: progName: spec:
    let
      root = pkgs.linkFarm "${userName}-${progName}-config" (
        mapAttrsToList (name: f: {
          inherit name;
          path = f.source;
        }) (filesFor user spec)
      );
    in
    pkgs.symlinkJoin {
      name = "${userName}-${progName}";
      paths = [ spec.package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${spec.bin} ${spec.flags root}
      '';

      meta = {
        mainProgram = spec.bin;
        description = "${spec.package.meta.description or progName}, wrapped with ${userName}'s config";
      };
    };

  wrappersFor =
    fullName:
    let
      userName = removePrefix "users." fullName;
      ev = standaloneUser fullName;
      user = ev.config;
      specs = candidates ev;
    in
    map (
      progName: nameValuePair "${userName}-${progName}" (wrap user userName progName specs.${progName})
    ) (builtins.filter (progName: filesFor user specs.${progName} != { }) (attrNames specs));
in
{
  packages = builtins.listToAttrs (concatMap wrappersFor userNames);
}
