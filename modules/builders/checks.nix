{ lib, config, ... }:
let
  buildable = lib.filterAttrs (name: _: config.registry.hosts.${name}.machineModules != [ ]);
in
{
  checks =
    lib.mapAttrs' (name: nixos: lib.nameValuePair "nixos-${name}" nixos.config.system.build.toplevel) (
      buildable config.nixosConfigurations
    )
    // lib.mapAttrs' (
      name: finix: lib.nameValuePair "finix-${name}" finix.config.system.build.toplevel
    ) (buildable config.finixConfigurations);
}
