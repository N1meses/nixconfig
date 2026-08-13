{ config, ... }: {
  aspects.bundle.cliEnv = {
    description = "Interactive shell environment: shell, file manager, editor, CLI tools and git.";
    includes = with config.aspectLib.names; [
      core.core
      bundle.shell
      desktop.apps.yazi
      dev.editors.helix
      dev.tools.cli
      dev.tools.git
    ];
  };
}
