{ config, ... }:
let
  flakeConfig = config;
in
{
  aspects.core.cachyosKernel = {
    description = "CachyOS performance kernel, via the pinned overlay.";
    nixos = { ... }: {
      imports = [ flakeConfig.aspectLib.all."core.overlays".nixos ];
    };
  };
}
