{
  description = "nixconfig - flakeless at heart; this wrapper only re-exports it";

  outputs =
    { self, ... }:
    let
      cfg = import ./. {
        rev = self.rev or (if self ? dirtyRev then builtins.substring 0 40 self.dirtyRev else "dirty");
      };

      sources = import ./.tack/default.nix;
      lib = import (sources.nixpkgs + "/lib");

      systems = builtins.attrNames cfg.devShells;
      forAll = lib.genAttrs systems;

      pkgsFor = system: import sources.nixpkgs { inherit system; };

      bySystem = set: system: lib.filterAttrs (_: drv: drv.system or null == system) set;
    in
    {
      inherit (cfg)
        nixosConfigurations
        finixConfigurations
        homeConfigurations
        diskoConfigurations
        deploy
        devShells
        images
        containers
        resolved
        ;

      checks = forAll (bySystem cfg.checks);
      packages = forAll (bySystem cfg.packages);
      formatter = forAll (system: (pkgsFor system).nixfmt-tree);
    };
}
