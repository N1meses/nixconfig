{config, ...}:
{
  flake.modules = {
    nixos.common = {...}: {
      imports = with config.flake.modules.nixos; [
        users
        core
        base
        shell
      ];
    };

    homeManager.common = {...}: {
      imports = with config.flake.modules.homeManager; [
        shell
        core
      ];
    };
  };
}
