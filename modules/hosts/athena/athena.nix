{ config, ... }: {
  registry.hosts.athena = {
    users = with config.registry.userNames; [ athena ];
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = [ "plugdev" ];
    hostId = "2e95e7c9";
    domain = "athena.tail4109e2.ts.net";
    aspects = with config.aspectLib.names; [
      base
      serverCore
      sshd
      nh
      hardwareAthena
      monitoring
      vaultwarden
      croc
      technitium
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

    homeModule = { ... }: {
      rum.programs.helix.settings.editor.clipboard-provider = "termcode";
    };
  };

  fleet.athena.home.ssh.matchBlocks.athena = {
    hostname = "100.75.163.80";
    user = "athena";
  };
}
