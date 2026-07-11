{
  config,
  inputs,
  ...
}: {
  registry.hosts.atlas = {
    username = "atlas";
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = ["plugdev"];
    hostId = "32947ba6";
    domain = "nimeses.com";
    aspects = with config.flake.lib.aspects; [
      server
      hardwareAtlas
      diskoAtlas
      monitoring
      forgejo
      jellyfin
      navidrome
      authentik
      cloudflared
      matrix
      element
      nixarr
      ocis
      fastfetch
    ];

    nixosModule = {
      pkgs,
      config,
      ...
    }: {
      imports = [inputs.disko.nixosModules.disko];

      features.server = {
        allowedUsers = ["atlas"];
        cloudflared.publicHosts =
          map (h: "${h}.${config.features.server.domain}")
          ["forgejo" "jellyfin" "navidrome" "auth" "matrix" "element" "cloud"];
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.initrd.systemd.enable = true;

      boot.kernelPackages = pkgs.linuxPackages_6_18;

      boot.initrd.network.enable = true;
      boot.initrd.network.flushBeforeStage2 = true;
      boot.initrd.systemd.network.networks."10-enp3s0" = {
        matchConfig.MACAddress = "b0:82:e2:41:dd:8e";
        address = ["192.168.68.10/22"];
        routes = [{Gateway = "192.168.68.1";}];
      };
      boot.initrd.network.ssh = {
        enable = true;
        port = 2222;
        hostKeys = ["/etc/secrets/initrd/ssh_host_ed25519_key"];
        authorizedKeys = let
          askPass = ''command="systemd-tty-ask-password-agent --query",no-port-forwarding,no-x11-forwarding,no-agent-forwarding'';
        in [
          "${askPass} sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPsZTxB0wavr8QZeOiFi+5jC2HhzHnJPfB38KFXrhwGWAAAABHNzaDo= yubikey-bio"
          "${askPass} sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAdtAWjHHeservujsnyP8YtRwdhn+Dx4P4gaf5t0hqC/AAAABHNzaDo= yubikey-nfc"
        ];
      };
      boot.initrd.network.ssh.extraConfig = ''
        PubkeyAcceptedAlgorithms +sk-ssh-ed25519@openssh.com
      '';

      networking.nameservers = ["192.168.68.1" "1.1.1.1"];
      networking.networkmanager.ensureProfiles.profiles.enp3s0 = {
        connection = {
          id = "enp3s0";
          type = "ethernet";
          interface-name = "enp3s0";
        };
        ipv4 = {
          method = "manual";
          address1 = "192.168.68.10/22,192.168.68.1";
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

    homeModule = {pkgs, ...}: {
      home.packages = with pkgs; [
        trash-cli
        nom
        nvd
        nix-tree
        tldr
        ani-cli
      ];

      programs.helix.settings.editor.clipboard-provider = "termcode";
      programs.ssh.settings."*".identityFile = ["~/.ssh/id_ed25519"];
    };
  };
}
