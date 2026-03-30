{config, inputs, ...}: {
  registry.hosts.hephaistos = {
    username = "hephaistos";
    system = "x86_64-linux";
    stateVersion = "25.05";
  };

  configurations.nixos.hephaistos.module = {pkgs, ...}: {
    imports = [ inputs.sops-nix.nixosModules.sops ] ++ (with config.flake.modules.nixos; [
      hardwareHephaistos
      common
      serverCore
      ssh
      nginx
      tailscale
      forgejo
      jellyfin
      vaultwarden
      croc
      cloudflared
    ]);

    networking.hostName = "hephaistos";

    features.server.domain = "hephaistos.tail4109e2.ts.net";

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-server;

    environment.systemPackages = with pkgs; [
      ntfs3g
      git
      wget
      wol
      wakeonlan
    ];
  };

  configurations.homeManager.hephaistos.module = {pkgs, ...}: {
    imports = with config.flake.modules.homeManager; [
      common
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
