{
  config,
  ...
}: {
  registry.hosts.nimeses = {
    username = "nimeses";
    system = "x86_64-linux";
    stateVersion = "25.11";
  };

  configurations.nixos.nimeses.module = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      users
      core
      hardware-nimeses
      base
      shell
    ];

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };

  configurations.homeManager.nimeses.module = {pkgs, ...}: {
    imports = with config.flake.modules.homeManager; [
      shell
      core
    ];


    programs.ssh.matchBlocks = {
      "hephaistos" = {
        hostname = "100.127.108.44";
        user = "hephaistos";
      };

      "prometheus" = {
        hostname = "100.93.27.90";
        user = "prometheus";
      };

      "nimeses" = {
        hostname = "100.83.164.93";
        user = "nimeses";
      };

      "forgejo" = {
        hostname = "100.127.108.44";
        user = "git";
        port = 2222;
      };
    };

    home.packages = with pkgs; [ btop ];
  };
}
