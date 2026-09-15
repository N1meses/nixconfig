{
  config,
  ...
}:
{
  hosts.atlas = {
    description = "Public-facing server: forgejo, binary cache, media, identity and matrix.";
    fleet = {
      nixos.nix.settings = {
        substituters = [ "http://atlas:5000" ];
        trusted-public-keys = [ "atlas-1:nd8FMmgrkHr4YT5AvMZhWVqGYvKEKi+5Lw1/Eg1k1wE=" ];
      };
      finix.services.nix-daemon.settings = {
        substituters = [ "http://atlas:5000" ];
        trusted-public-keys = [ "atlas-1:nd8FMmgrkHr4YT5AvMZhWVqGYvKEKi+5Lw1/Eg1k1wE=" ];
      };
      home.ssh.matchBlocks = {
        atlas = {
          hostname = "100.68.232.99";
          user = "atlas";
        };
        forgejo = {
          hostname = "100.68.232.99";
          user = "forgejo";
          port = 2222;
        };
        "atlas-unlock" = {
          hostname = "192.168.68.50";
          port = 2222;
          user = "root";
          proxyJump = "athena";
        };
      };
    };
    classes = [ "nixos" ];
    machineModules = [
      ./_hardware.nix
      ./_boot.nix
      ./_disko.nix
      {
        networking.hostId = "32947ba6";
        features.server.domain = "nimeses.com";
      }
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
      server.share.forgejo
      server.binaryCache
      server.forgejoRunner
      server.media.jellyfin
      server.security.authentik
      server.vpn.cloudflared
      server.share.matrix
      server.share.element
      server.media.nixarr
      server.media.openCloud
      server.media.collabora
      users.atlas
    ];

    nixos =
      {
        pkgs,
        config,
        ...
      }:
      {
        features.server = {
          allowedUsers = [ "atlas" ];
          cloudflared.publicHosts = map (h: "${h}.${config.features.server.domain}") [
            "forgejo"
            "jellyfin"
            "auth"
            "matrix"
            "element"
            "cloud"
            "office"
          ];
        };

        networking.nameservers = [
          "192.168.68.53"
          "1.1.1.1"
        ];
        networking.networkmanager.ensureProfiles.profiles.enp3s0 = {
          connection = {
            id = "enp3s0";
            type = "ethernet";
            interface-name = "enp3s0";
          };
          ipv4 = {
            method = "manual";
            address1 = "192.168.68.50/22,192.168.68.1";
          };
          ipv6.method = "auto";
        };

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
      ssh.matchBlocks."*".identityFile = [ "~/.ssh/id_ed25519" ];
      ssh.matchBlocks.forgejo = {
        hostname = "100.68.232.99";
        user = "forgejo";
        port = 2222;
      };
    };
  };

}
