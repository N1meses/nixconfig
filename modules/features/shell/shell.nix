{ config, ... }: {
  aspects.bundle.shell = {
    description = "Shell stack: zsh, fzf/zoxide tooling, the starship prompt and ssh client config.";
    includes = with config.aspectLib.names; [
      shell.zsh
      shell.shellTools
      shell.starship
      shell.ssh
    ];
  };
}
