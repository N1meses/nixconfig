{ config, ... }: {
  registry.hosts.hephaistos = {
    users = with config.registry.userNames; [ hephaistos ];
    system = "x86_64-linux";
    stateVersion = "25.05";
    extraGroups = [ "plugdev" ];
    domain = "hephaistos.tail4109e2.ts.net";
    aspects = with config.aspectLib.names; [
      server
      hardwareHephaistos
      vaultwarden
      croc
      nix
      fastfetch
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

    homeModule = { pkgs, ... }: {
      packages = with pkgs; [
        trash-cli
        nom
        nvd
        nix-tree
        tldr
      ];
      rum.programs.helix.settings.editor.clipboard-provider = "termcode";
    };
  };
}
