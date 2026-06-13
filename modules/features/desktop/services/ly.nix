{...}: {
  flake.modules = {
    nixos.ly = {...}: {
      services.displayManager.ly = {
        enable = true;
        settings = {
          clock = "%c";
        };
      };

      security.pam.services.ly.enableGnomeKeyring = true;
    };

    finix.ly = {...}: {
      services.ly = {
        enable = true;
        settings = {
          clock = "%c";
        };
      };
    };
  };
}
