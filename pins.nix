{
  pins.nixpkgs = {
    url = "https://github.com/NixOS/nixpkgs";
    ref = "nixos-unstable";
    patches = [
      { pr = 566386; }
    ];
    importable = true;
  };

  pins.finix = {
    url = "https://github.com/finix-community/finix";
  };

  pins.hjem = {
    url = "https://github.com/feel-co/hjem";
  };

  pins.hjem-rum = {
    url = "https://github.com/snugnug/hjem-rum";
  };

  pins.halley = {
    url = "https://github.com/N1meses/halley";
    ref = "feat/flake";
  };

  pins.disko = {
    url = "https://github.com/nix-community/disko";
    excludeFollow = [ "nixpkgs" ];
  };

  pins.impermanence = {
    url = "https://github.com/nix-community/impermanence";
    excludeFollow = [ "nixpkgs" ];
  };

  pins.pnix = {
    type = "git";
    url = "https://github.com/bunny-systems/pnix";
    flake = false;
  };
}
