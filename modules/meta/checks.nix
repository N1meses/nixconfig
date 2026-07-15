{lib, config, ...}: {
    flake.checks =
      lib.mapAttrs'
      (name: nixos: lib.nameValuePair "host-${name}" nixos.config.system.build.toplevel)
      (lib.filterAttrs
        (name: _: !(lib.hasSuffix "Minimal" name))
        config.flake.nixosConfigurations);
  }
