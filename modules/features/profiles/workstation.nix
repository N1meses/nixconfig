{ config, ... }: {
  aspects.bundle.workstation = {
    description = "Full graphical workstation: base plus CLI environment, desktop, niri, display manager and editors.";
    includes = with config.aspectLib.names; [
      bundle.base
      bundle.cliEnv
      bundle.desktop
      desktop.compositors.niri
      desktop.services.ly
      dev.languages.nix
      dev.tools.nixIndex
      dev.editors.zed
      desktop.apps.term.kitty
    ];
  };
}
