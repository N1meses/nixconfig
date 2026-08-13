_: {
  aspects.direnv.description = "direnv with zsh integration.";
  aspects.direnv.home = _: {
    rum.programs.direnv = {
      enable = true;
      integrations.zsh.enable = true;
    };
  };
}
