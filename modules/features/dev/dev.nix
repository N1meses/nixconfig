{config, ...}: {
  flake.modules.homeManager.dev = {...}: {
    imports = with config.flake.modules.homeManager; [
      languages
      editors
    ];
  };
}
