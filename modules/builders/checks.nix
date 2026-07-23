{ lib, config, ... }: {
  checks =
    lib.mapAttrs' (
      name: nixos: lib.nameValuePair "nixos-${name}" nixos.config.system.build.toplevel
    ) config.nixosConfigurations
    // lib.mapAttrs' (
      name: finix: lib.nameValuePair "finix-${name}" finix.config.system.build.toplevel
    ) config.finixConfigurations;
}
