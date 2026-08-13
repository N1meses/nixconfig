{ inputs, ... }: {
  aspects.nixIndex.description = "nix-index and command-not-found lookup.";
  aspects.nixIndex.nixos = {
    imports = [ inputs.nix-index-database.nixosModules.nix-index ];
    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
    programs.command-not-found.enable = false;
  };
}
