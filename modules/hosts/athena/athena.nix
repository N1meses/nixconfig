{
  config,
  inputs,
  ...
}: {
  registry.hosts.athena = {
    username = "athena";
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = ["plugdev"];
    hostId = "2e95e7c9";
    git = {
      name = "N1meses";
      email = "nilshasenthal@gmail.com";
    };
    aspects = with config.flake.lib.aspects; [
      core
      shell
      hardwareAthena
      users
      local
      serverCore
      sshd
      nginx
      monitoring
      tailscale
      forgejo
      jellyfin
      nextcloud
      navidrome
      authentik
      cloudflared
      matrix
      element
      nixarr
      helix
      yazi
      nh
      fastfetch
      git
      network
    ];
  };

  configurations.nixos.athena.module = {pkgs, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops = {
      defaultSopsFile = ../../../secrets/athena.yaml;
      age.sshKeyPaths = [];
      age.keyFile = "/root/.config/sops/age/keys.txt";
    };

    networking.hostName = "athena";

    features.server = {
      domain = "nimeses.com";
      allowedUsers = ["athena"];
    };

    boot.kernelPackages = pkgs.linuxPackages_6_18;

    environment.systemPackages = with pkgs; [
      ntfs3g
      git
      wget
      nix
      wol
      wakeonlan
      sops
    ];
  };

  configurations.homeManager.athena.module = {pkgs, ...}: {
    home.packages = with pkgs; [
      trash-cli
      nom
      nvd
      nix-tree
      tldr
      ani-cli
    ];
  };
}
