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
  };

  configurations.nixos.hermes.module = {lib, ...}: {
    imports =
      [
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
      ]
      ++ (with config.flake.modules.nixos; [
        hardwareHermes
        diskoHermes
        impermanenceHermes
        users
        core
        base
        shell
        greetd
        niri
        fonts
      ]);

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

  configurations.homeManager.hermes.module = {pkgs, ...}: {
    imports = with config.flake.modules.homeManager; [
      core
      shell
      nh
      helix
      foot
      niri
      waybar
      fuzzel
      mako
      wallpaper
      yazi
      browser
    ];

    features.compositors = {
      wallpaper.image = ../../../assets/icons/wallpaper.jpg;
      niri.extraBinds = {
        "Mod+n" = {spawn = "fuzzel";};
      };
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
