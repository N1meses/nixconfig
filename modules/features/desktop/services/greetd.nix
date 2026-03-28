{...}: {
  flake.modules.nixos.greetd = {pkgs, config, lib, ...}: {
    options.features.services.greetd.enable = lib.mkEnableOption "greetd display manager";

    config = lib.mkIf config.features.services.greetd.enable {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = lib.mkDefault "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd niri";
          user = "greeter";
        };
      };
      security.pam.services.greetd.enableGnomeKeyring = true;
    };
  };
}
