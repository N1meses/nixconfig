{
  lib,
  config,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks =
      (lib.mapAttrs'
        (name: nixos: lib.nameValuePair "host-${name}" nixos.config.system.build.toplevel)
        (lib.filterAttrs
          (_: nixos: nixos.config.nixpkgs.hostPlatform.system == system)
          config.flake.nixosConfigurations))
      // {
        registry-sync = let
          reg = lib.attrNames config.registry.hosts;
          cfg = lib.unique (
            lib.attrNames config.configurations.nixos
            ++ lib.attrNames config.configurations.finix
            ++ lib.attrNames config.configurations.homeManager
          );
          orphanCfg = lib.subtractLists reg cfg;
          orphanReg = lib.subtractLists cfg reg;
          bad = orphanCfg ++ orphanReg;
        in
          if bad == []
          then pkgs.runCommand "registry-sync-ok" {} "touch $out"
          else throw "registry/configurations mismatch: ${lib.concatStringsSep ", " bad}";
      };
  };
}
