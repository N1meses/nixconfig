{
  lib,
  config,
  ...
}: {
  perSystem = {system, ...}: {
    checks =
      lib.mapAttrs'
      (name: nixos: lib.nameValuePair "host-${name}" nixos.config.system.build.toplevel)
      (lib.filterAttrs
        (_: nixos: nixos.config.nixpkgs.hostPlatform.system == system)
        config.flake.nixosConfigurations);
  };
}
