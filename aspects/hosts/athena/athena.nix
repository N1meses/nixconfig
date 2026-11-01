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
      server.base.core
      server.base.sshd
      desktop.apps.nh
      server.base.monitoring
      server.identity.vaultwarden
      server.files.croc
      server.network.technitium
      users.athena
    ];

    nixos =
      {
        pkgs,
        ...
      }:
      {
        features.server = {
          allowedUsers = [ "athena" ];
          # the tailnet domain isn't a verified sender at scaleway
          mail = {
            from = "noreply@notify.nimeses.com";
            relay.username = "106c5581-d276-40c6-ba37-1451f7510db2"; # scaleway TEM project
          };
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

    home = { ... }: {
      rum.programs.helix.settings.editor.clipboard-provider = "termcode";
    };
  };

}
