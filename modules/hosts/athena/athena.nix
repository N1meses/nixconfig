{ config, ... }: {
  registry.hosts.athena = {
    username = "athena";
    users = with config.registry.userNames; [ athena ];
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = [ "plugdev" ];
    hostId = "2e95e7c9";
    domain = "athena.tail4109e2.ts.net";
    aspects = with config.aspectLib.names; [
      server
      hardwareAthena
      monitoring
      vaultwarden
      croc
      technitium
      fastfetch
    ];

    nixosModule =
      {
        pkgs,
        ...
      }:
      {
        features.server.allowedUsers = [ "athena" ];

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

    homeModule = { pkgs, ... }: {
      packages = with pkgs; [
        trash-cli
        nom
        nvd
        nix-tree
        tldr
        ani-cli
      ];

      rum.programs.helix.settings.editor.clipboard-provider = "termcode";
    };
  };
}
