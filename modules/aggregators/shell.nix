{config, ...}: {
  aspects.shell.includes = with config.aspectLib.names; [
    zsh
    shellTools
    starship
    ssh
  ];
}
