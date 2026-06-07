{inputs, ...}: {
  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned
    ];
  };
}
