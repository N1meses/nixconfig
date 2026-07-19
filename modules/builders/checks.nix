{ lib, config, ... }: {
  checks =
    lib.mapAttrs' (name: nixos: lib.nameValuePair "host-${name}" nixos.config.system.build.toplevel) (
      lib.filterAttrs (name: _: !(lib.hasSuffix "Minimal" name)) config.nixosConfigurations
    )
    // lib.mapAttrs' (
      name: finix: lib.nameValuePair "finix-${name}" finix.config.system.build.toplevel
    ) config.finixConfigurations;
}
