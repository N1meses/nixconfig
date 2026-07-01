{config, ...}: {
  registry.hosts.athena = {
    username = "athena";
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = ["plugdev"];
    hostId = "2e95e7c9";
    domain = "nimeses.com";
    aspects = with config.flake.lib.aspects; [
      core
      shell
      hardwareAthena
      users
      local
      serverCore
      sshd
      monitoring
      tailscale
      forgejo
      jellyfin
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

    nixosModule = {
      pkgs,
      config,
      ...
    }: {
      features.server = {
        allowedUsers = ["athena"];
        cloudflared.publicHosts =
          map (h: "${h}.${config.features.server.domain}")
          ["forgejo" "jellyfin" "navidrome" "auth" "matrix" "element"];
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

    homeModule = {pkgs, ...}: {
      home.packages = with pkgs; [
        trash-cli
        nom
        nvd
        nix-tree
        tldr
        ani-cli
      ];
    };
  };
}
