{config, ...}: {
  flake.aspectInclude.shell = with config.flake.lib.aspects; [
    zsh
    shellTools
    starship
    ssh
  ];
}
