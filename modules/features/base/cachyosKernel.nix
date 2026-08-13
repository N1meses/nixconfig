{ config, ... }:
let
  flakeConfig = config;
in
{
  aspects.cachyosKernel.description = "CachyOS performance kernel, via the pinned overlay.";
  aspects.cachyosKernel.nixos = { ... }: {
    imports = [ flakeConfig.aspects.overlays.nixos ];
  };
}
