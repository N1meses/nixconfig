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
    git = {
      name = "N1meses";
      email = "nilshasenthal@gmail.com";
    };
    aspects = with config.flake.lib.aspects; [
      core
      shell
      hardwareHephaistos
      users
      local
      sshd
      nginx
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
  };

  configurations.nixos.hephaistos.module = {pkgs, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

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
    home.packages = with pkgs; [
      trash-cli
      nom
      nvd
      nix-tree
      tldr
    ];
  };
}
