{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config.aspectLib)
    all
    commonOverlays
    aspectsFor
    modulesFor
    resolve
    wrapperKey
    wrapperModule
    ;

  hostPkgs = pkgs.appendOverlays commonOverlays;

  hjem-lib = import "${inputs.hjem}/lib.nix" {
    inherit lib;
    pkgs = hostPkgs;
  };

  portable =
    aspectName:
    let
      names = resolve [ aspectName ];
      ev = lib.evalModules {
        specialArgs = {
          inherit hjem-lib;
          pkgs = hostPkgs;
          name = "portable";
          osConfig = null;
          userEntry = null;
        };
        modules = [
          "${inputs.hjem}/modules/common/user.nix"
          inputs.hjem-rum.hjemModules.default
          { directory = "/var/empty"; }
          (wrapperModule names)
        ]
        ++ aspectsFor modulesFor.home names;
      };
    in
    ev.config.wrapped.${wrapperKey aspectName};

  withWrapper = builtins.filter (n: all.${n}.wrapper or null != null) (builtins.attrNames all);
  byKey = lib.groupBy wrapperKey withWrapper;

  wrappers = lib.mapAttrs (
    key: owners:
    if builtins.length owners > 1 then
      throw "wrapper: aspects ${toString owners} all export packages.${key}"
    else
      portable (builtins.head owners)
  ) byKey;
in
{
  packages = wrappers;

  checks.wrappers = pkgs.runCommand "check-wrappers" { } ''
    export HOME=/var/empty
    ${lib.concatMapStringsSep "\n" (
      name:
      let
        p = wrappers.${name};
      in
      ''
        echo "${name}: ${lib.getExe p} --version"
        ${lib.getExe p} --version >/dev/null
      ''
    ) (builtins.attrNames wrappers)}
    touch $out
  '';
}
