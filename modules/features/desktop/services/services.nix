{ config, ... }:
{
  aspects.services.includes = with config.aspectLib.names; [
    graphics
    fonts
    portals
    audio
    bluetooth
    userServices
  ];
}
