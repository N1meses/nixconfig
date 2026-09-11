{ inputs, ... }: {
  aspects.dev.tools.nixIndex = {
    description = "nix-index and command-not-found lookup.";
    nixos = {
      imports = [ inputs.nix-index-database.nixosModules.nix-index ];
      programs.nix-index.enable = true;
      programs.nix-index-database.comma.enable = true;
      programs.command-not-found.enable = false;
    };
  };

  pins.nix-index-database = {
      url = "https://github.com/nix-community/nix-index-database";
      excludeFollow = [ "nixpkgs" ];
  };
}
