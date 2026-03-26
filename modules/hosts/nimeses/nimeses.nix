{config, ...}: {
  registry.hosts.nimeses = {
    username = "nimeses";
    system = "x86_64-linux";
    stateVersion = "25.11";
  };

  features = {
    dev = {
      editors = {
        helix.enable = true;
        zed.enable = true;
      };

      languages = {
        nix.enable = true;
        python.enable = true;
      };

      tools = {
        ai.enable = true;
      };
    };
  };

  configurations.nixos.nimeses.module = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [
      hardware-nimeses
      common
    ];

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };

  configurations.homeManager.nimeses.module = {...}: {
    imports = with config.flake.modules.homeManager; [
      common
      dev
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
  };
}
