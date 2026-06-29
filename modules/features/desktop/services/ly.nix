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
      lib,
      ...
    }: {
      imports = [modules.ly];
      services.getty.enable = lib.mkForce false;

      services.ly = {
        enable = true;
        settings = {
          clock = "%c";
        };
      };
    };
  };
}
