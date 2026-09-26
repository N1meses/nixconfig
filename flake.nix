{
  description = "nixconfig - flakeless at heart; this wrapper only re-exports it";

  outputs =
    { self, ... }:
    let
      # See default.nix: a patched pin is a derivation, and this evaluation is
      # pure, so the system cannot be read from `builtins.currentSystem`. Both
      # call sites below must agree with default.nix's own default.
      patchSystem = "x86_64-linux";

      cfg = import ./. {
        inherit patchSystem;
        rev = self.rev or (if self ? dirtyRev then builtins.substring 0 40 self.dirtyRev else "dirty");
      };

      sources = import ./.pnix {
        system = patchSystem;
        allFollow = {
          nixpkgs = "nixpkgs";
          hjem = "hjem";
        };
      };

      inherit (sources.nixpkgs) lib;

      forAll = lib.genAttrs cfg.aspectLib.systems;

      pkgsFor = system: import sources.nixpkgs { inherit system; };

      bySystem = set: system: lib.filterAttrs (_: drv: drv.system or null == system) set;
    in
    {
      inherit (cfg)
        nixosConfigurations
        finixConfigurations
        homeConfigurations
        diskoConfigurations
        devShells
        deploy
        ;

      checks = forAll (bySystem cfg.checks);
      packages = forAll (bySystem cfg.packages);

      nixosModules = cfg.aspectLib.modulesFor.nixos;
      finixModules = cfg.aspectLib.modulesFor.finix;
      homeModules = cfg.aspectLib.modulesFor.home;

      lib = cfg.aspectLib;

      formatter = forAll (system: (pkgsFor system).nixfmt-tree);
    };
}
