{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.cachyosKernel = {...}: {
    imports = [flakeConfig.flake.modules.nixos.overlays];
  };
}
