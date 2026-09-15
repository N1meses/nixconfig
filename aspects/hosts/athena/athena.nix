{ config, ... }: {
  hosts.athena = {
    hostId = "2e95e7c9";
    domain = "athena.tail4109e2.ts.net";
    description = "Tailnet server: DNS, password vault, monitoring and file drop.";
    fleet.home.ssh.matchBlocks.athena = {
      hostname = "100.75.163.80";
      user = "athena";
    };
    classes = [ "nixos" ];
    machineModules = [
      ./_hardware.nix
      ../_uefi-systemd-boot.nix
    ];
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = [ "plugdev" ];
    includes = with config.aspectLib.aspectNames; [
      bundle.base
      dev.tools.git
      server.serverCore
      server.sshd
      desktop.apps.nh
      server.monitoring
      server.security.vaultwarden
      server.share.croc
      server.technitium
      users.athena
    ];

    nixos =
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

    home = { ... }: {
      rum.programs.helix.settings.editor.clipboard-provider = "termcode";
    };
  };

}
