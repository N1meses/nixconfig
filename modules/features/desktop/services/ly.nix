_: {
  flake.modules = {
    nixos.ly = _: {
      services.displayManager.ly = {
        enable = true;
        settings = {
          clock = "%c";
        };
      };

      security.pam.services.ly.enableGnomeKeyring = true;
    };

    finix.ly = {
      modules,
      ...
    }: {
      imports = [modules.ly];

      services.ly = {
        enable = true;
        settings = {
          clock = "%c";
        };
      };
    };
  };
}
