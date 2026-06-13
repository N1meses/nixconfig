{config, ...}: let
  flakeConfig = config;
in {
  flake.modules = {
    nixos.shell = {...}: {
      imports = with flakeConfig.flake.modules.nixos; [
        zsh
      ];
    };

    finix.shell = {
      imports = with flakeConfig.flake.modules.nixos; [
        zsh
      ];
    };

    homeManager.shell = {...}: {
      imports = with flakeConfig.flake.modules.homeManager; [
        shellTools
        starship
        zsh
        ssh
      ];
    };
  };
}
