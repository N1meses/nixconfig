{ inputs, ... }: {
  aspects.overlays.description = "Fleet-wide nixpkgs overlays (pinned CachyOS kernel).";
  aspects.overlays.nixos = {
    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned
    ];
  };
}
