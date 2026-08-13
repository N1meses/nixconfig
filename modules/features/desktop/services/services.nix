{ config, ... }:
{
  aspects.services.description = "Desktop plumbing every graphical session needs: graphics, fonts, portals, audio, bluetooth and user services.";
  aspects.services.includes = with config.aspectLib.names; [
    graphics
    fonts
    portals
    audio
    bluetooth
    userServices
  ];
}
