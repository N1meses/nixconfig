{config, ...}: let
  flakeConfig = config;
in {
  aspects.cachyosKernel.nixos = {...}: {
    imports = [flakeConfig.aspects.overlays.nixos];
  };
}
