{
  config,
  inputs,
  ...
}: {
  registry.hosts.hermes = {
    username = "hermes";
    system = "x86_64-linux";
    stateVersion = "25.11";
    extraGroups = ["video" "input"];
    git = {
      name = "N1meses";
      email = "nilshasenthal@gmail.com";
    };
    aspects = with config.flake.lib.aspects; [
      core
      shell
      services
      niri
      noctalia
      hardwareHermes
      diskoHermes
      impermanenceHermes
      ly
      users
      base
      rescue
      tailscale
      nh
      helix
      foot
      yazi
      browser
    ];
  };

  configurations.nixos.hermes.module = {lib, ...}: {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
    ];

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

    networking.hostName = "hermes";
    hardware.graphics.enable = true;

    users.users.hermes.hashedPassword = "$6$Bo/x3FIcMJKIpnqD$5Txn123BHqMQOPpnE2166p2JgziMybskSBHFX6FBmjd25.mF6ElOk4KZiKEY4aq.1EXjudASi/.0nQp7Oj6fp/";

    programs.nix-ld.enable = lib.mkForce false;

    services.journald.extraConfig = ''
      SystemMaxUse=50M
      RuntimeMaxUse=10M
    '';
  };

  configurations.homeManager.hermes.module = {
    pkgs,
    lib,
    ...
  }: let
    flakeRoot = inputs.self;
  in {
    # hermes roams and is impermanent: override noctalia's nimeses Pictures path
    # with the in-repo wallpaper, and drop the inherited per-monitor paths so it
    # applies regardless of the machine's monitor names.
    programs.noctalia.settings.wallpaper = {
      directory = lib.mkForce "${flakeRoot}/assets/icons";
      default.path = lib.mkForce "${flakeRoot}/assets/icons/wallpaper.jpg";
      last.path = lib.mkForce "${flakeRoot}/assets/icons/wallpaper.jpg";
      monitors = lib.mkForce {};
    };

    home.pointerCursor = {
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      size = 24;
      gtk.enable = true;
    };

    home.packages = with pkgs; [
      btop
    ];
  };
}
