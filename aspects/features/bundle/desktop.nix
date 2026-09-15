{ config, ... }: {
  aspects.bundle.desktop = {
    description = "Graphical desktop bundle: session services, apps and the noctalia shell.";
    includes = with config.aspectLib.aspectNames; [
      bundle.services
      bundle.apps
      desktop.apps.yaziFilechooser
      desktop.noctalia
    ];
  };
}
