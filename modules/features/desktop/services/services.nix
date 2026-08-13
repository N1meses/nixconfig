{ config, ... }:
{
  aspects.bundle.services = {
    description = "Desktop plumbing every graphical session needs: graphics, fonts, portals, audio, bluetooth and user services.";
    includes = with config.aspectLib.names; [
      desktop.services.graphics
      desktop.services.fonts
      desktop.services.portals
      desktop.services.audio
      desktop.services.bluetooth
      desktop.services.userServices
    ];
  };
}
