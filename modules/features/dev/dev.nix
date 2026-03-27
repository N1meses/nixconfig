{config, ...}: {
  flake.modules.homeManager.dev = {...}: {
    imports = with config.flake.modules.homeManager; [
      tools
      languages
      editors
    ];
  };
}
