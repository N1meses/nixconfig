{...}: {
  flake.modules.nixos.greetd = {pkgs, lib, ...}: {
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = lib.mkDefault "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd niri";
        user = "greeter";
      };
    };
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
