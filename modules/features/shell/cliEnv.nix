{ config, ... }: {
  aspects.cliEnv.description = "Interactive shell environment: shell, file manager, editor, CLI tools and git.";
  aspects.cliEnv.includes = with config.aspectLib.names; [
    core
    shell
    yazi
    helix
    cli
    git
  ];
}
