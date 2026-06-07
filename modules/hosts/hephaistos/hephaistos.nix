{
  config,
  inputs,
  ...
}: {
  registry.hosts.hephaistos = {
    username = "hephaistos";
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = ["plugdev"];
  };

  configurations.nixos.hephaistos.module = {pkgs, ...}: {
    imports =
      [inputs.sops-nix.nixosModules.sops]
      ++ (with config.flake.modules.nixos; [
        hardwareHephaistos
        users
        core
        base
        shell
        serverCore
        ssh
        nginx
        tailscale
        vaultwarden
        croc
      ]);

    networking.hostName = "hephaistos";

    features.server.domain = "hephaistos.tail4109e2.ts.net";

    users.users.hephaistos.hashedPassword = "$6$Bo/x3FIcMJKIpnqD$5Txn123BHqMQOPpnE2166p2JgziMybskSBHFX6FBmjd25.mF6ElOk4KZiKEY4aq.1EXjudASi/.0nQp7Oj6fp/";

    sops = {
      defaultSopsFile = ../../../secrets/hephaistos.yaml;
      age.sshKeyPaths = [];
      age.keyFile = "/root/.config/sops/age/keys.txt";
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;

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
      core
      shell
      helix
      yazi
      nh
      nix
      fastfetch
      git
      network
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
