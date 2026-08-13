{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  hosts = config.registry.hosts;
  finixModules = config.aspectLib.finixModules;
  aspectsFor = config.aspectLib.aspectsFor;
  resolveAspects = config.aspectLib.resolveAspects;
  mkHomeModules = config.aspectLib.mkHomeModules;

  testLib = import "${inputs.finix}/tests/lib" {
    inherit (pkgs) lib;
    pkgs = pkgs.extend inputs.halley.overlays.default;
  };

  fleetFor =
    layer: self: map (f: f.${layer}) (builtins.attrValues (removeAttrs config.fleet [ self ]));

  # A VM is not this machine, so `host.machineModules` is simply never spliced in.
  # That replaces the old name-prefix heuristic ("disko*", "hardware*", luks,
  # impermanence), which only worked as long as nobody named an aspect badly.
  vmAspectNames =
    host:
    resolveAspects (host.aspects ++ lib.concatMap (u: config.registry.users.${u}.aspects) host.users);

  homeModule =
    name: host:
    {
      hjem.extraModules = [ inputs.hjem-rum.hjemModules.default ];
      hjem.users = lib.genAttrs host.users (uname: {
        enable = true;
        imports = [
          (mkHomeModules {
            inherit host;
            user = config.registry.users.${uname};
          })
        ]
        ++ fleetFor "home" name;
      });
    }
    // lib.optionalAttrs (host.domain != "") {
      features.server.domain = host.domain;
    };

  vmNode = name: host: {
    _module.args.hostName = name;
    _module.args.hostEntry = host;
    imports = [
      host.finixModule
    ]
    ++ aspectsFor finixModules (vmAspectNames host)
    ++ [
      inputs.hjem.finixModules.default
      (homeModule name host)
      finixModules.mkVM
    ]
    ++ fleetFor "finix" name;
  };

  mkHostVm =
    name: host:
    (testLib.mkTest {
      name = "${name}-vm";
      nodes.machine = vmNode name host;
      testScript = "start_all()";
      extraDriverArgs = [ "--interactive" ];
    }).driverInteractive;

  finixHosts = lib.filterAttrs (_: host: host.finixModule != null) hosts;
in
{
  packages = lib.mapAttrs' (
    name: host: lib.nameValuePair "vm-${name}" (mkHostVm name host)
  ) finixHosts;
}
