{ config, ... }: {
  aspects.cliEnv.includes = with config.aspectLib.names; [
    shell
    yazi
    helix
    cli
    git
  ];
}
