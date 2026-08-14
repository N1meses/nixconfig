{ config, ... }: {
  aspects.bundle.desktop = {
    description = "Graphical desktop bundle: session services, apps and the noctalia shell.";
    includes = with config.aspectLib.names; [
      bundle.services
      bundle.apps
      desktop.apps.yaziFilechooser
      desktop.noctalia
    ];
  };
}
