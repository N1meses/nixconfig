{config, ...}: {
  registry.hosts.hephaistos = {
    username = "hephaistos";
    system = "x86_64-linux";
    stateVersion = "25.05";
  };

  configurations.nixos.hephaistos.module = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      hardwareHephaistos
      common
      server
    ];

    networking.hostName = "hephaistos";

    features.server = {
      domain = "hephaistos.tail4109e2.ts.net";
      tailscale.enable = true;
      forgejo.enable = true;
      jellyfin.enable = true;
      vaultwarden.enable = true;
      croc.enable = true;
      cloudflared.enable = true;
    };

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
