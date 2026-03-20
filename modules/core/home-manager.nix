{...}:
{
  flake.modules.homeManager.core = {lib, ...}: {
    programs.home-manager.enable = true;

    xdg.enable = true;

    home.sessionVariables = {
      EDITOR = lib.mkDefault "hx";
    };
  };
}
