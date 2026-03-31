{config, inputs, ...}: {
  registry.hosts.athena = {
    username = "athena";
    system = "x86_64-linux";
    stateVersion = "25.05";
  };

  configurations.nixos.athena.module = {pkgs, ...}: {
    imports = [ inputs.sops-nix.nixosModules.sops ] ++ (with config.flake.modules.nixos; [
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
    ]);

    networking.hostName = "athena";

    features.server = {
      domain = "athena.tail4109e2.ts.net";
      allowedUsers =  ["athena"];
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;

    environment.systemPackages = with pkgs; [
      ntfs3g
      git
      wget
      wol
      wakeonlan
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

    home.packages = with pkgs; [
      trash-cli
      nom
      nvd
      nix-tree
      tldr
    ];
  };
}
