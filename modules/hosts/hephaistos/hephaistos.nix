{
  config,
  ...
}: {
  registry.hosts.hephaistos = {
    username = "hephaistos";
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = ["plugdev"];
    aspects = with config.flake.lib.aspects; [
      core
      shell
      hardwareHephaistos
      users
      local
      sshd
      tailscale
      vaultwarden
      croc
      helix
      yazi
      nh
      nix
      fastfetch
      git
      network
    ];

    nixosModule = {pkgs, ...}: {
      features.server.domain = "hephaistos.tail4109e2.ts.net";

      boot.kernelPackages = pkgs.linuxPackages_latest;

      environment.systemPackages = with pkgs; [
        ntfs3g
        git
        wget
        wol
        wakeonlan
      ];
    };

    homeModule = {pkgs, ...}: {
      home.packages = with pkgs; [
        trash-cli
        nom
        nvd
        nix-tree
        tldr
      ];
    };
  };
}
