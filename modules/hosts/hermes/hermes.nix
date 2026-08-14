{
  config,
  inputs,
  ...
}:
let
  mkNoctaliaNiri = config.aspectLib.mkNoctaliaNiri;
in
{
  registry.hosts.hermes = {
    machineModules = [
      ./_hardware.nix
      ./_boot.nix
      ./_disko.nix
      ./_impermanence.nix
    ];
    users = with config.registry.userNames; [ hermes ];
    system = "x86_64-linux";
    stateVersion = "25.11";
    extraGroups = [
      "video"
      "input"
    ];
    hostId = "50fb8101";
    aspects = with config.aspectLib.names; [
      bundle.base
      dev.tools.git
      core.cachyosKernel
      profile.rescue
      desktop.services.ly
      desktop.apps.nh
    ];

    nixosModule = { lib, ... }: {
      users.users.hermes.hashedPasswordFile = "/persist/passwords/hermes";
      users.users.root.hashedPasswordFile = "/persist/passwords/hermes";

      hardware.graphics.enable = true;

      programs.nix-ld.enable = lib.mkForce false;

      services.journald.extraConfig = ''
        SystemMaxUse=50M
        RuntimeMaxUse=10M
      '';
    };

    homeModule =
      {
        lib,
        ...
      }:
      let
        flakeRoot = inputs.self;
      in
      {
        noctalia.settings.wallpaper = {
          directory = "${flakeRoot}/assets/icons";
          default.path = "${flakeRoot}/assets/icons/wallpaper.jpg";
          last.path = "${flakeRoot}/assets/icons/wallpaper.jpg";
          monitors = [ ];
        };

        features.compositors.niri.extraBinds = {
          "Mod+Shift+q" = {
            spawn = mkNoctaliaNiri "session lock";
          };
          "Mod+n" = {
            spawn = mkNoctaliaNiri "panel-toggle launcher";
          };
          "Mod+b" = {
            spawn = mkNoctaliaNiri "bar-toggle";
          };
        };
      };
  };
}
