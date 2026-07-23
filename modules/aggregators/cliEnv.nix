{ config, ... }: {
  aspects.cliEnv.includes = with config.aspectLib.names; [
    core
    shell
    yazi
    helix
    cli
    git
  ];
}
