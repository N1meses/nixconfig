{ config, ... }: {
  aspects.bundle.desktop = {
    description = "Graphical desktop bundle: session services, apps, the noctalia shell and session wiring.";
    includes = with config.aspectLib.names; [
      bundle.services
      bundle.apps
      desktop.apps.yaziFilechooser
      desktop.noctalia
      finix.session
    ];
  };
}
