{ config, ... }: {
  registry.hosts.hephaistos = {
    users = with config.registry.userNames; [ hephaistos ];
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = [ "plugdev" ];
    domain = "hephaistos.tail4109e2.ts.net";
    aspects = with config.aspectLib.names; [
      base
      serverCore
      sshd
      nh
      hardwareHephaistos
      vaultwarden
      croc
    ];

    nixosModule = { pkgs, ... }: {
      boot.kernelPackages = pkgs.linuxPackages_latest;

      environment.systemPackages = with pkgs; [
        ntfs3g
        git
        wget
        wol
        wakeonlan
      ];
    };

    homeModule = { ... }: {
      rum.programs.helix.settings.editor.clipboard-provider = "termcode";
    };
  };

  fleet.hephaistos.home.ssh.matchBlocks.hephaistos = {
    hostname = "100.127.108.44";
    user = "hephaistos";
  };
}
