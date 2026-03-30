{...}: {
  flake.modules.homeManager.core = {...}: {
    programs.home-manager.enable = true;
    xdg.enable = true;
  };
}
