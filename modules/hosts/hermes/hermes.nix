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
    username = "hermes";
    system = "x86_64-linux";
    stateVersion = "25.11";
    extraGroups = [
      "video"
      "input"
    ];
    hostId = "50fb8101";
    aspects = with config.aspectLib.names; [
      base
      hardwareHermes
      diskoHermes
      impermanenceHermes
      cachyosKernel
      rescue
      services
      niri
      noctalia
      ly
      nh
      foot
      yazi
      browser
    ];

    nixosModule = { lib, ... }: {
      imports = [
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
      ];

      users.users.hermes.hashedPasswordFile = "/persist/passwords/hermes";
      users.users.root.hashedPasswordFile = "/persist/passwords/hermes";

      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = lib.mkDefault "/dev/sda";
      };

      boot.loader.grub.forceInstall = true;
      boot.plymouth.enable = false;
      boot.loader.systemd-boot.enable = false;
      boot.loader.efi.canTouchEfiVariables = false;

      hardware.graphics.enable = true;

      programs.nix-ld.enable = lib.mkForce false;

      services.journald.extraConfig = ''
        SystemMaxUse=50M
        RuntimeMaxUse=10M
      '';
    };

    homeModule =
      {
        pkgs,
        lib,
        ...
      }:
      let
        flakeRoot = inputs.self;
      in
      {
        noctalia.settings.wallpaper = {
          directory = lib.mkForce "${flakeRoot}/assets/icons";
          default.path = lib.mkForce "${flakeRoot}/assets/icons/wallpaper.jpg";
          last.path = lib.mkForce "${flakeRoot}/assets/icons/wallpaper.jpg";
          monitors = lib.mkForce { };
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

        packages = with pkgs; [
          btop
          claude-code
          sops
        ];
      };
  };
}
