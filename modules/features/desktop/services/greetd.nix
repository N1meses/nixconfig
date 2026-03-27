{config, lib, ...}: let
  cfg = config.features.services.greetd;
in {
  options.features.services.greetd.sessionCmd = lib.mkOption {
    type = lib.types.str;
    default = "niri";
    description = "Session command launched by tuigreet (passed to --cmd)";
  };

  config.flake.modules.nixos.greetd = {pkgs, ...}: {
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd ${cfg.sessionCmd}";
        user = "greeter";
      };
    };
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
