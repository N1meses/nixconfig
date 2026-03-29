{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.shell = {...}: {
    imports = with flakeConfig.flake.modules.nixos; [
      zsh
    ];
  };

  flake.modules.homeManager.shell = {...}: {
    imports = with flakeConfig.flake.modules.homeManager; [
      shellTools
      starship
      zsh
      ssh
    ];
  };
}
