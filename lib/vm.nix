{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    elem
    filterAttrs
    mapAttrs'
    nameValuePair
    optional
    ;

  inherit (config.aspectLib) classes hostModules modulesFor;

  testLib = import "${inputs.finix}/tests/lib" {
    inherit (pkgs) lib;
    pkgs = pkgs.extend (
      lib.composeExtensions inputs.halley.overlays.default inputs.umbriel.overlays.default
    );
  };

  mkVm =
    name: host:
    (testLib.mkTest {
      name = "${name}-vm";
      nodes.machine = {
        imports = hostModules {
          inherit name host;
          cls = classes.finix;
          machine = false;
          extra = optional (modulesFor.finix ? "profile.mkVM") modulesFor.finix."profile.mkVM";
        };
      };
      testScript = "start_all()";
      extraDriverArgs = [ "--interactive" ];
    }).driverInteractive;

  vmable = filterAttrs (_: host: elem "finix" host.classes) config.hosts;
in
{
  packages = mapAttrs' (name: host: nameValuePair "${name}-vm" (mkVm name host)) vmable;
}
