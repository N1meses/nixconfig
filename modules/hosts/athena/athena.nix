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
  };

  configurations.nixos.athena.module = {pkgs, ...}: {
    imports =
      [inputs.sops-nix.nixosModules.sops]
      ++ (with config.flake.modules.nixos; [
        hardwareAthena
        users
        core
        base
        shell
        serverCore
        ssh
        nginx
        tailscale
        forgejo
        jellyfin
        nextcloud
        navidrome
        authentik
        cloudflared
        matrix
        nixarr
        mullvad
      ]);

    sops = {
      defaultSopsFile = ../../../secrets/athena.yaml;
      age.sshKeyPaths = [];
      age.keyFile = "/root/.config/sops/age/keys.txt";
    };

    networking = {
      hostName = "athena";
      hostId = "2e95e7c9";
    };

    features.server = {
      domain = "nimeses.com";
      allowedUsers = ["athena"];
    };

    boot.kernelPackages = pkgs.linuxPackages_6_6;

    environment.systemPackages = with pkgs; [
      ntfs3g
      git
      wget
      wol
      wakeonlan
      sops
    ];
  };

  configurations.homeManager.athena.module = {pkgs, ...}: {
    imports = with config.flake.modules.homeManager; [
      core
      shell
      helix
      yazi
      nh
      fastfetch
      git
      network
    ];

    programs.git.settings.user = {
      name = "N1meses";
      email = "nilshasenthal@gmail.com";
    };

    home.packages = with pkgs; [
      trash-cli
      nom
      nvd
      nix-tree
      tldr
    ];
  };
}
