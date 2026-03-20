{...}:
{
  flake.modules.homeManager.git = {...}: {
    programs = {
      git = {
        enable = true;
        delta.enable = true;
      };

      lazygit.enable = true;
    };
  };
}
