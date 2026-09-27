{ inputs, ... }:
let
  modules = inputs.finix.nixosModules;
in
{
  aspects.desktop.services.ly = {
    nixos = _: {
      services.displayManager.ly = {
        enable = true;
        settings = {
          clock = "%c";
        };
      };

      security.pam.services.ly.enableGnomeKeyring = true;
    };

    finix = _: {
      imports = [ modules.ly ];

      services.ly = {
        enable = true;
        settings = {
          clock = "%c";
        };
      };
    };
    description = "ly display manager.";
  };
}
