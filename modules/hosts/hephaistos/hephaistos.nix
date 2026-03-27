{
  config,
  lib,
  ...
}: {
  registry.hosts.hephaistos = {
    username = "hephaistos";
    system = "x86_64-linux";
    stateVersion = "25.05";
  };

  features = {
    apps = {
      yazi.enable = true;
      nh.enable = true;
      fastfetch.enable = true;
    };

    dev.editors.helix.enable = true;

    server = {
      # TODO: switch to nimeses.com once Cloudflare Tunnel is configured
      domain = "hephaistos.tail4109e2.ts.net";
      forgejo.enable = true;
      jellyfin.enable = true;
      vaultwarden.enable = true;
      croc.enable = true;
      cloudflared.enable = true;
    };
  };

  configurations.nixos.hephaistos.module = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      hardware-hephaistos
      common
      server
    ];

    networking = {
      hostName = "hephaistos";
      firewall.trustedInterfaces = ["tailscale0"];
    };

    services.tailscale.enable = true;

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-server;

    environment.systemPackages = with pkgs; [
      ntfs3g
      git
      wget
      wol
      wakeonlan
      # wake-prometheus needs sops secrets — add after sops setup
    ];
  };

  configurations.homeManager.hephaistos.module = {pkgs, ...}: {
    imports = with config.flake.modules.homeManager; [
      common
      dev
      apps
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
