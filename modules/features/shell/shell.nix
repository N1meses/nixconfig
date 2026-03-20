{config, ...}:
{
  flake.modules.nixos.shell = {...}: {
    imports = with config.flake.modules.nixos; [
      zsh
    ];
  };

  flake.modules.homeManager.shell = {...}: {
    imports = with config.flake.modules.homeManager; [
      shell-tools
      starship
      zsh
    ];
  };
}
