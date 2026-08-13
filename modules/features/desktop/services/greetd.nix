_: {
  aspects.greetd.description = "greetd display manager with the tuigreet frontend.";
  aspects.greetd = {
    nixos =
      {
        pkgs,
        lib,
        ...
      }:
      {
        services.greetd = {
          enable = true;
          settings.default_session = {
            command = lib.mkDefault "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
            user = "greeter";
          };
        };
        security.pam.services.greetd.enableGnomeKeyring = true;
      };

    finix = { modules, ... }: {
      imports = [ modules.tuigreet ];

      programs.tuigreet.enable = true;
      services.greetd.settings.terminal.vt = 1;
    };
  };
}
