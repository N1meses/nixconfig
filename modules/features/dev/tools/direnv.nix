_: {
  aspects.dev.tools.direnv = {
    description = "direnv with zsh integration.";
    home = _: {
      rum.programs.direnv = {
        enable = true;
        integrations.zsh.enable = true;
      };
    };
  };
}
