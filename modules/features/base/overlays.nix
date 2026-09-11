{ inputs, ... }: {
  aspects.core.overlays = {
    description = "Fleet-wide nixpkgs overlays (pinned CachyOS kernel).";
    nixos = {
      nixpkgs.overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
      ];
    };
  };

  pins.nix-cachyos-kernel = {
    url = "https://github.com/xddxdd/nix-cachyos-kernel";
    excludeFollow = [ "nixpkgs" ];
  };
}
