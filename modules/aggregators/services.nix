{ config, ... }:
let
  flakeConfig = config;
in
{
  aspects.services = {
    nixos = { ... }: {
      imports = with config.aspectLib.nixosModules; [
        graphics
        fonts
        portals
        audio
        bluetooth
      ];
    };

    home = { ... }: {
      imports = with config.aspectLib.homeModules; [
        userServices
      ];
    };

    finix = { ... }: {
      imports = with config.aspectLib.finixModules; [
        fonts
        ly
        audio
        bluetooth
      ];
    };
  };
}
