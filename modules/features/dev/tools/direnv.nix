_: {
  aspects.direnv.home = _: {
    rum.programs.direnv = {
      enable = true;
      integrations.zsh.enable = true;
    };
  };
}
