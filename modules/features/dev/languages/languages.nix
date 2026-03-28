{ config, ... }: let flakeConfig = config; in {
  flake.modules.homeManager.languages = { ... }: {
    imports = with flakeConfig.flake.modules.homeManager;
      [ bash c css go html java javascript json lua markdown nix puml python rust yaml zig ];
  };
}
