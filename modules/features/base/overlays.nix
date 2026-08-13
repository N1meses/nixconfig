{ inputs, ... }: {
  aspects.core.overlays = {
    description = "Fleet-wide nixpkgs overlays (pinned CachyOS kernel).";
    nixos = {
      nixpkgs.overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
      ];
    };
  };
}
