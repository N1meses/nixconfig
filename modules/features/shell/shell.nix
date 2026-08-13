{ config, ... }: {
  aspects.shell.description = "Shell stack: zsh, fzf/zoxide tooling, the starship prompt and ssh client config.";
  aspects.shell.includes = with config.aspectLib.names; [
    zsh
    shellTools
    starship
    ssh
  ];
}
