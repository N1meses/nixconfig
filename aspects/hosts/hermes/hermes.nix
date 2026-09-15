{
  config,
  inputs,
  ...
}:
let
  mkNoctaliaUmbriel = config.aspectLib.mkNoctaliaUmbriel;
in
{
  hosts.hermes = {
    hostId = "50fb8101";
    description = "Rescue and installer stick; persists its own passwords and doubles as recovery.";
    classes = [ "nixos" ];
    machineModules = [
      ./_hardware.nix
      ./_boot.nix
      ./_disko.nix
      ./_impermanence.nix
    ];
    system = "x86_64-linux";
    stateVersion = "25.11";
    extraGroups = [
      "video"
      "input"
    ];
    includes = with config.aspectLib.aspectNames; [
      bundle.base
      dev.tools.git
      core.cachyosKernel
      profile.rescue
      desktop.services.ly
      desktop.apps.nh
      users.hermes
    ];

    nixos = { lib, ... }: {
      users.users.hermes.hashedPasswordFile = "/persist/passwords/hermes";
      users.users.root.hashedPasswordFile = "/persist/passwords/hermes";

      hardware.graphics.enable = true;

      programs.nix-ld.enable = lib.mkForce false;

      services.journald.settings.Journal = {
        SystemMaxUse = "50M";
        RuntimeMaxUse = "10M";
      };
    };

    home =
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

        features.compositors.umbriel.extraBinds = {
          "Mod+Shift+q" = mkNoctaliaUmbriel "session lock";
          "Mod+n" = mkNoctaliaUmbriel "panel-toggle launcher";
          "Mod+b" = mkNoctaliaUmbriel "bar-toggle";
        };
      };
  };
}
