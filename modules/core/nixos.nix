{...}:
{
  flake.modules.nixos.core = {pkgs, lib, ...}: {

    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages;

      plymouth.enable = lib.mkDefault true;

      loader = {
        grub.enable = lib.mkForce false;
        systemd-boot = {
          enable = lib.mkDefault true;
          editor = lib.mkDefault false;
          configurationLimit = lib.mkDefault 10;
        };
        efi.canTouchEfiVariables = lib.mkDefault true;
      };

      initrd = {
        systemd.enable = lib.mkDefault true;
        verbose = lib.mkDefault false;
      };
    };

    nix = {
      settings = {

        experimental-features = [
          "nix-command"
          "flakes"
        ];

        auto-optimise-store = true;

        trusted-users = [
          "@wheel"
          "root"
        ];

        download-buffer-size = 524288000;
        http-connections = 50;
        max-substitution-jobs = 16;

        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    };

    networking.networkmanager.enable = lib.mkDefault true;
    networking.firewall.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      git
      helix
      curl
      wget
    ];
  };
}
