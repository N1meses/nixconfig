{
  description = "nixconfig - flakeless at heart; this wrapper only re-exports it";

  outputs =
    { self, ... }:
    let
      cfg = import ./. {
        rev = self.rev or (if self ? dirtyRev then builtins.substring 0 40 self.dirtyRev else "dirty");
      };

      sources = import ./.pnix {
        allFollow = {
          nixpkgs = "nixpkgs";
          hjem = "hjem";
        };
      };

      inherit (sources.nixpkgs) lib;

      forAll = lib.genAttrs cfg.aspectLib.systems;

      pkgsFor = system: import sources.nixpkgs { inherit system; };
    in
    {
      inherit (cfg)
        nixosConfigurations
        finixConfigurations
        homeConfigurations
        diskoConfigurations
        ;

      nixosModules = cfg.aspectLib.modulesFor.nixos;
      finixModules = cfg.aspectLib.modulesFor.finix;
      homeModules = cfg.aspectLib.modulesFor.home;

      lib = cfg.aspectLib;

      formatter = forAll (system: (pkgsFor system).nixfmt-tree);
    };
}
